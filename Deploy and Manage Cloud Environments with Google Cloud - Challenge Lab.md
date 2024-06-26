# Deploy and Manage Cloud Environments with Google Cloud - Challenge Lab

In the terminal in the new browser window, install the pglogical database extension:
```
sudo apt install postgresql-13-pglogical
```

Download and apply some additions to the PostgreSQL configuration files (to enable pglogical extension) and restart the postgresql service:


```
sudo su - postgres -c "gsutil cp gs://cloud-training/gsp918/pg_hba_append.conf ."
sudo su - postgres -c "gsutil cp gs://cloud-training/gsp918/postgresql_append.conf ."
sudo su - postgres -c "cat pg_hba_append.conf >> /etc/postgresql/13/main/pg_hba.conf"
sudo su - postgres -c "cat postgresql_append.conf >> /etc/postgresql/13/main/postgresql.conf"
sudo systemctl restart postgresql@13-main
```

3 Launch the psql tool:
```



sudo su - postgres
psql
```


4Add the pglogical database extension to the postgres, orders and gmemegen_db databases.


\c postgres;
```sql
CREATE EXTENSION pglogical;
```
\c orders;
```sql
CREATE EXTENSION pglogical;
```
\c gmemegen_db;
```sql
CREATE EXTENSION pglogical;
```

5 List the PostgreSQL databases on the server:
```
\l

—--------------------------------------------------------
—--------------------------------------------------------


Create the database migration user
```sql

CREATE USER migration_admin PASSWORD 'DMS_1s_cool!';
ALTER DATABASE orders OWNER TO migration_admin;
ALTER ROLE migration_admin WITH REPLICATION;


\c postgres;
GRANT USAGE ON SCHEMA pglogical TO migration_admin;
GRANT ALL ON SCHEMA pglogical TO migration_admin;
GRANT SELECT ON pglogical.tables TO migration_admin;
GRANT SELECT ON pglogical.depend TO migration_admin;
GRANT SELECT ON pglogical.local_node TO migration_admin;
GRANT SELECT ON pglogical.local_sync_status TO migration_admin;
GRANT SELECT ON pglogical.node TO migration_admin;
GRANT SELECT ON pglogical.node_interface TO migration_admin;
GRANT SELECT ON pglogical.queue TO migration_admin;
GRANT SELECT ON pglogical.replication_set TO migration_admin;
GRANT SELECT ON pglogical.replication_set_seq TO migration_admin;
GRANT SELECT ON pglogical.replication_set_table TO migration_admin;
GRANT SELECT ON pglogical.sequence_state TO migration_admin;
GRANT SELECT ON pglogical.subscription TO migration_admin;



\c orders;
GRANT USAGE ON SCHEMA pglogical TO migration_admin;
GRANT ALL ON SCHEMA pglogical TO migration_admin;
GRANT SELECT ON pglogical.tables TO migration_admin;
GRANT SELECT ON pglogical.depend TO migration_admin;
GRANT SELECT ON pglogical.local_node TO migration_admin;
GRANT SELECT ON pglogical.local_sync_status TO migration_admin;
GRANT SELECT ON pglogical.node TO migration_admin;
GRANT SELECT ON pglogical.node_interface TO migration_admin;
GRANT SELECT ON pglogical.queue TO migration_admin;
GRANT SELECT ON pglogical.replication_set TO migration_admin;
GRANT SELECT ON pglogical.replication_set_seq TO migration_admin;
GRANT SELECT ON pglogical.replication_set_table TO migration_admin;
GRANT SELECT ON pglogical.sequence_state TO migration_admin;
GRANT SELECT ON pglogical.subscription TO migration_admin;



GRANT USAGE ON SCHEMA public TO migration_admin;
GRANT ALL ON SCHEMA public TO migration_admin;
GRANT SELECT ON public.distribution_centers TO migration_admin;
GRANT SELECT ON public.inventory_items TO migration_admin;
GRANT SELECT ON public.order_items TO migration_admin;
GRANT SELECT ON public.products TO migration_admin;
GRANT SELECT ON public.users TO migration_admin;


\c gmemegen_db;
GRANT USAGE ON SCHEMA pglogical TO migration_admin;
GRANT ALL ON SCHEMA pglogical TO migration_admin;
GRANT SELECT ON pglogical.tables TO migration_admin;
GRANT SELECT ON pglogical.depend TO migration_admin;
GRANT SELECT ON pglogical.local_node TO migration_admin;
GRANT SELECT ON pglogical.local_sync_status TO migration_admin;
GRANT SELECT ON pglogical.node TO migration_admin;
GRANT SELECT ON pglogical.node_interface TO migration_admin;
GRANT SELECT ON pglogical.queue TO migration_admin;
GRANT SELECT ON pglogical.replication_set TO migration_admin;
GRANT SELECT ON pglogical.replication_set_seq TO migration_admin;
GRANT SELECT ON pglogical.replication_set_table TO migration_admin;
GRANT SELECT ON pglogical.sequence_state TO migration_admin;
GRANT SELECT ON pglogical.subscription TO migration_admin;



GRANT USAGE ON SCHEMA public TO migration_admin;
GRANT ALL ON SCHEMA public TO migration_admin;
GRANT SELECT ON public.meme TO migration_admin;


\c orders;
\dt
ALTER TABLE public.distribution_centers OWNER TO migration_admin;
ALTER TABLE public.inventory_items OWNER TO migration_admin;
ALTER TABLE public.order_items OWNER TO migration_admin;
ALTER TABLE public.products OWNER TO migration_admin;
ALTER TABLE public.users OWNER TO migration_admin;
\dt



ALTER TABLE public.inventory_items ADD PRIMARY KEY(id);
\q 
exit

—--------------------------------------------------------
—--------------------------------------------------------
```


Create a new continuous Database Migration Service job.


In the Google Cloud Console, on the Navigation menu (), click Database Migration > Connection profiles.
Click + Create Profile.
For Source database engine, select PostgreSQL.
For Connection profile name, enter postgres-vm.
For Hostname or IP address, enter the internal IP for the PostgreSQL source instance that you copied in the previous task (e.g., 10.128.0.2)
For Port, enter 5432.
For Username, enter migration_admin.
For Password, enter DMS_1s_cool! .
For all other values leave the defaults.
Click Create.

—--------------------------------------------------------
—--------------------------------------------------------



Create a new continuous migration job
In this step you will create a new continuous migration job.
In the Google Cloud Console, on the Navigation menu (), click Database Migration > Migration jobs.
Click + Create Migration Job.
For Migration job name, enter postgres-vm.
For Source database engine, select PostgreSQL
For Migration job type, select Continuous.
Leave the defaults for the other settings.
Click Save & Continue.
—--------------------------------------------------------
—--------------------------------------------------------

As part of the migration job configuration, make sure that you specify the following properties for the destination Cloud SQL instance:
The Destination Instance ID must be set to Migrated Cloud SQL for PostgreSQL Instance ID
The Password for the migrated instance must be set to supersecret!
Database version must be set to Cloud SQL for PostgreSQL 13
Region must be set to us-central1
For Connections both Public IP and Private IP must be set
Select a standard machine type with 1 vCPU
For Storage type, use SSD
Set the storage capacity to 10 GB
For the Connectivity Method, you must use VPC peering with the default VPC network.





—--------------------------------------------------------
—--------------------------------------------------------




