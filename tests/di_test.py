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
            }

            module "data_ingest" {
              source = "./mymodule"

              providers = {
                aws = aws
              }

              appsvpc_id                   = "1234"
              opssubnet_cidr_block         = "1.2.3.0/24"
              data_ingest_cidr_block       = "10.1.6.0/24"
              data_ingest_rds_cidr_block   = "10.1.7.0/24"
              peering_cidr_block           = "1.1.1.0/24"
              az                           = "eu-west-2a"
              az2                          = "eu-west-2b"
              naming_suffix                = "apps-prod-dq"
              logging_bucket_id            = "dq-bucket-name"
              archive_bucket               = "dq-test"
              archive_bucket_name          = "dq-test"
              apps_buckets_kms_key         = "arn:aws:kms:eu-west-2:123456789:key/654dy74520786elkfugho4576lfk;suh358976"
              environment                  = "prod"
              rds_enhanced_monitoring_role = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
            }
        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

if __name__ == '__main__':
    unittest.main()
