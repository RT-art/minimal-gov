env      = "dev"
app_name = "minimal-gov-dev-rds"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

db_name               = "app"
username              = "dbadmin"
password              = "DummyPass1234!"
vpc_cidr              = "10.0.0.0/16"
engine                = "postgres"
engine_version        = "15"
instance_class        = "db.t3.micro"
allocated_storage     = 20
multi_az              = false
backup_retention_days = 7
skip_final_snapshot   = true
apply_immediately     = true
