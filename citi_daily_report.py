import pandas as pd
import io
from datetime import datetime


import snowflake.connector
# Create connection to Snowflake using your account and user



query1 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_WGE_SUMMARY"
query2 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_AGENT_SUMMARY"
query3 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_SESSIONS"
query4 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_QUOTES;"
query5 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_ILLUSTRATIONS;"
query6 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_APP_REQUESTS;"
query7 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_APP_SUBMITS;"
query8 = "select * from COVR_ANALYTICS.PRODUCTION.CITI_YTD_APP_PAID;"


sqlList = {"WGE_SUMMARY": query1, "AGENT_SUMMARY": query2, "SESSIONS": query3, "QUOTES": query4,
           "ILLUSTRATIONS": query5, "APP_REQUESTS": query6, "APP_SUBMITS": query7, "APP_PAID": query8}

filename = f"D:\data_extracts\external\output\citi\CITI_{datetime.now():%Y_%m_%d}.xlsx"

writer = pd.ExcelWriter(filename, engine='xlsxwriter',
                        datetime_format='mm/dd/yyyy')

for dF in sqlList:
    conn = snowflake.connector.connect(
        user='gwellbrock',
        password='Yeahiti$1Yeahiti$1',
        account='covrtech.west-us-2.azure',
        ocsp_fail_open=False,
    )
    print(dF)

   
    print("Executing")
# print(sql)
    print(conn)
    val = sqlList[dF]
    sql = val
    print(sql)
    dataframe = pd.DataFrame(pd.read_sql_query(sql,conn))
    dataframe.to_excel(writer, sheet_name=dF,
                       startrow=1, header=False, index=False
                       )
    workbook = writer.book
    worksheet = writer.sheets[dF]
    (max_row, max_col) = dataframe.shape
    column_settings = []
    for header in dataframe.columns:
        column_settings.append({'header': header})
    worksheet.add_table(0, 0, max_row, max_col - 1,
                        {'columns': column_settings})
    worksheet.set_column(0, max_col - 1, 20)



writer.save()




import paramiko
paramiko.util.log_to_file("paramiko.log")

# Open a transport
host,port = "10.110.3.4",9922
transport = paramiko.Transport((host,port))

# Auth    
username,password = "covr.filedrop","$G$zgopd7W870DX^E2lw"
transport.connect(None,username,password)

path='/FileDrop/Citibank/daily_report'
# Go!    
sftp = paramiko.SFTPClient.from_transport(transport)
sftp.chdir(path)

# Upload
upload_file_name = f"CITI_{datetime.now():%Y_%m_%d}.xlsx"
filepath = upload_file_name
localpath = filename
sftp.put(localpath,filepath)



# Close
if sftp: sftp.close()
if transport: transport.close()