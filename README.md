# delete-default-vpc
Deletes AWS default VPCs in all regions (bash)
## Description
This scripts deletes the default VPC in all regions. The use case can be if you want to provision special custom version of VPC.
AWS provisions in all region default VPCs. The default VPC facilitates the start up phase. You can deploy EC2 without making network design in advance.

## Precondition

AWS CLI installed and configured
 
## Usage


There are two options

`--profile` gives the aws cli profile. You can use default or dedicated profile

`--dry-run`  if only needs to simulates and do not delete

The scripts provides the cumulative number of errors during the execution. If more then zero(0) then you need to  look deeper.

```
./remove_default_vpc.sh -h
delete default VPC in all regions
usage: remove_default_vpc.sh [-h] --profile | -p PROFILE_NAME
                            --dry-run
```

Example

```
./remove_default_vpc.sh  -p profile12

delete default VPC in all regions

removing in region ap-south-1

# deleting vpc (vpc-12341234aqws) ...
#   deleting subnet (subnet-66778899) ...
#   deleting subnet (subnet-55667788) ...
#   deleting internet gateway (igw-1a1a1a1a) ...

removing in region eu-west-3

# deleting vpc (vpc-a1a1a1a1a1) ...
...
...
```
## License

MIT

