#!/bin/bash
#
#

dryRunOption="--no-dry-run"
profile="default"
errCount=0
version="0.1 TZV"

function usage
{
    echo "usage: remove_default_vpc.sh [-h] --profile | -p PROFILE_NAME 
    					    --dry-run"
}

function remove_default_vpc_in_region
{
      region=$1
      echo "removing in region ${region}"
      
      vpcID=$(aws ec2 describe-vpcs --region ${region} --profile ${profile} --filters "Name=isDefault,Values=true" --output text --query 'Vpcs[*].{Vpc:VpcId}') 
      if [ -z ${vpcID} ]; then 
	      echo "# no default vpc"	
	      return 0
      fi

      echo "# deleting vpc (${vpcID}) ..."

      for subnetID in $(aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpcID} --region ${region} --profile ${profile} \
	      --query "Subnets[*].{Subnets:SubnetId}" --output text); 
        do
          echo "#   deleting subnet (${subnetID}) ..."
	  aws ec2 delete-subnet --subnet-id ${subnetID} --region ${region} --profile ${profile} ${dryRunOption} || errCount=$((errCount+1))
        done

      for igwID in $(aws ec2 describe-internet-gateways --filter Name=attachment.vpc-id,Values=${vpcID} --region ${region} --profile ${profile} \
	      --query 'InternetGateways[*].{InternetGateway:InternetGatewayId}' --output text  ); 
        do
          echo "#   deleting internet gateway (${igwID}) ..."
          aws ec2 detach-internet-gateway --internet-gateway-id=${igwID} --vpc-id=${vpcID} --region ${region} --profile ${profile} \
		  ${dryRunOption} || errCount=$((errCount+1))
	  aws ec2 delete-internet-gateway --internet-gateway-id=${igwID} --region ${region} --profile ${profile} \
		  ${dryRunOption} || errCount=$((errCount+1))
        done

     aws ec2 delete-vpc --vpc-id ${vpcID} --region ${region} --profile ${profile} ${dryRunOption} || errCount=$((errCount+1))

}


echo "start delete default VPCs in all regions $versoin" 

while [ "$1" != "" ]; do
    case $1 in
        -p | --profile )   	shift
	     		        profile=$1
                                ;;
        -d | --dry-run ) 	dryRunOption="--dry-run"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
    esac
    shift
done

for region in $(aws ec2 describe-regions --output text --query 'Regions[*].{Regions:RegionName}'); 
  do
	 remove_default_vpc_in_region $region
  done

if (( ${errCount} == 0 )); then 
	 echo "delete successful"
else
	 echo "There were ${errCount} Errors. See output"
fi




