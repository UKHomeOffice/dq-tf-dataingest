# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "data_ingest" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }

              appsvpc_id                   = "1234"
              opssubnet_cidr_block         = "1.2.3.0/24"
              data_ingest_cidr_block       = "10.1.6.0/24"
              data_ingest_rds_cidr_block   = "10.1.7.0/24"
              peering_cidr_block           = "1.1.1.0/24"
              az                           = "eu-west-2a"
              az2                          = "eu-west-2b"
              naming_suffix                = "apps-preprod-dq"
              logging_bucket_id            = "dq-bucket-name"
              archive_bucket               = "dq-test"
              archive_bucket_name          = "dq-test"
              apps_buckets_kms_key         = "arn:aws:kms:eu-west-2:123456789:key/654dy74520786elkfugho4576lfk;suh358976"
              environment                  = "pre-prod"
              rds_enhanced_monitoring_role = "arn:aws:iam::123456789:role/rds-enhanced-monitoring-role"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_ingest_subnet(self):
        self.assertEqual(self.result['data_ingest']["aws_subnet.data_ingest"]["cidr_block"], "10.1.6.0/24")

    def test_name_suffix_data_ingest(self):
        self.assertEqual(self.result['data_ingest']["aws_subnet.data_ingest"]["tags.Name"], "subnet-dataingest-apps-preprod-dq")

    def test_name_suffix_rds_subnet(self):
        self.assertEqual(self.result['data_ingest']["aws_subnet.data_ingest_az2"]["tags.Name"], "az2-subnet-dataingest-apps-preprod-dq")

    def test_name_suffix_mds_subnet_group(self):
        self.assertEqual(self.result['data_ingest']["aws_db_subnet_group.mds_rds"]["tags.Name"], "mds-rds-subnet-group-dataingest-apps-preprod-dq")

    def test_name_suffix_mds_db(self):
        self.assertEqual(self.result['data_ingest']["aws_security_group.mds_db"]["tags.Name"], "sg-mds-db-dataingest-apps-preprod-dq")

if __name__ == '__main__':
    unittest.main()
