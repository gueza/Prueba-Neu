import pandas as pd
class DataCSV:
    def __init__(self):
        self.records = pd.read_csv('../records.csv')
        self.tariffs = pd.read_csv('../tariffs.csv')
        self.services = pd.read_csv('../services.csv')
        self.injection = pd.read_csv('../injection.csv')
        self.consumption = pd.read_csv('../consumption.csv')
        self.xm_data_hourly_per_agent = pd.read_csv('../xm_data_hourly_per_agent.csv')

class GenerateBill:

    @staticmethod
    def generate_bill_neu(data, id_service):

        data_service = data.services[data.services['id_service'] == id_service]
        voltage_level_number = data_service['voltage_level'].values[0]

        consumption = data.consumption[
            data.consumption['id_record'].isin(data.records[data.records['id_service'] == id_service]['id_record'])
        ]
        consumption_amount = consumption['value'].sum()

        injection = data.injection[
            data.injection['id_record'].isin(data.records[data.records['id_service'] == id_service]['id_record'])
        ]
        injection_amount = injection['value'].sum()


        if voltage_level_number in [2, 3]:

            cu_tariff = data.tariffs[data.tariffs['voltage_level'].isin([2, 3]) & data.tariffs['id_market'].isin(data.services[data.services['id_service'] == id_service]['id_market'])]['CU'].values[0]

        else:
            cu_tariff = data.tariffs[
                (data.tariffs['id_market'] == data_service['id_market'].values[0]) &
                (data.tariffs['cdi'] == data_service['cdi'].values[0]) &
                (data.tariffs['voltage_level'] == voltage_level_number)
                ]['CU'].values[0]
            
        c_tariff = data.tariffs[(data.tariffs['id_market'] == data_service['id_market'].values[0]) & (data.tariffs['voltage_level'] == voltage_level_number)]['C'].values[0]

        EC = injection_amount * c_tariff
        EA = consumption_amount * cu_tariff
        

        if injection_amount <= consumption_amount:
            EE1 = injection_amount * (-cu_tariff)
        else:
            EE1 = consumption_amount * (-cu_tariff)


        if injection_amount <= consumption_amount:
            EE2 = 0
        else:
            ee2_merge = pd.merge(data.records, data.xm_data_hourly_per_agent, on = 'record_timestamp', how = 'outer') 
            ee2_merge = pd.merge(ee2_merge, consumption, on ='id_record', how = 'outer')
            ee2_merge = pd.merge(ee2_merge, injection, on = 'id_record', how = 'outer')
            ee2_merge.fillna(0, inplace = True) # lo que está indefinido a cero porque no está relacionado
            ee2_filter = ee2_merge[ee2_merge['id_service'] == id_service]

            column_rename = {
                'value_x': 'value_data_hourly',
                'value_y': 'value_consumption',
                'value': 'value_injection',
            }
            ee2_filter.rename(columns = column_rename, inplace = True)

            ee2_filter['ee2_result'] = (ee2_filter['value_consumption'] - ee2_filter['value_injection']) * ee2_filter['value_data_hourly']
            EE2 = ee2_filter['ee2_result'].sum()

        results = pd.DataFrame({'id_service': id_service, 'EA': [EA], 'EC': [EC], 'EE1': [EE1], 'EE2': [EE2]})

        return results


    def run_services(self, data):
        results = []
        for service_id in data.services['id_service']:
            data_csv = self.generate_bill_neu(data, service_id)
            if data_csv is not None:
                results.append(data_csv)

        return pd.concat(results)


if __name__ == '__main__':
    data = DataCSV()
    calculator = GenerateBill()
    results_dataframe = calculator.run_services(data)
    # results_dataframe = calculator.generate_bill_neu(data, 2478)
    print(results_dataframe.sort_values(by='id_service'))

