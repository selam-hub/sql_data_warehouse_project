# sql_data_warehouse_project
building a modern data warehouse with SQL Server including ETL process , data modeling and analytic.
our source data format is csv files from two systems: CRM & ERP.
We are going to use medallion architecture : 
1) Bronze layer: retaining raw data for trackability and debugging , the object will be table
2) silver layer: applying data tarnsformation(cleansing(handling duplication, null valuse, invalid values, spaces, data type casting ), data enrichment, standarsization, derived columns , normalization ),  the object will be table
3) Gold layer: contains curated data (aggregation, applied business rules, integration, calculating key metrics),  the object will be view, here we design and build data modeling using star schema 

we do full data loading using truncating and insert. the data processing will be batch . no need for historical data.

