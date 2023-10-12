clustername="eks-vector"
namespace="spark"
region="us-east-1"
role_name="emr-eks-job-execution-ROLE"
execution_role_arn="arn:aws:iam::228924278364:role/emr-eks-managed-endpoint-job-execution-ROLE"
emr_release_label="emr-6.13.0-latest"

alb_policy_arn="arn:aws:iam::228924278364:policy/EMR-EKS-Load-Balancer-Controller-Policy"
vpcid="vpc-053a5a66bfb63a3ce"
certdomain="*.emreksdemo.com"
virtendpointname="vector-embedding-endpoint"

virt_name="vector-virt-1"

virt_cluster_id=$(aws emr-containers list-virtual-clusters --query 'virtualClusters[?name==`'"${virt_name}"'`].id | [0]' | sed 's/"//g')

eksctl create iamserviceaccount \
  --cluster=${clustername} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=${alb_policy_arn} \
  --override-existing-serviceaccounts \
  --region ${region} \
  --approve

roleArn=$(eksctl get iamserviceaccount \
  --cluster ${clustername} \
  --region ${region} \
  --output json | jq '.[] | select(.metadata.name=="aws-load-balancer-controller")' | jq .status.roleARN | sed 's/"//g' | sed 's/\//\\\//g')

rm lb-controller.yaml
cp lb-controller.yaml.template lb-controller.yaml

sedstr="s/%alb_role_arn%/${roleArn}/"
sed -i ${sedstr} lb-controller.yaml

# Create service account on the cluster

kubectl apply -f lb-controller.yaml

# Install the TargetGroupBinding custom resource definitions

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm repo add eks https://aws.github.io/eks-charts

# Install the AWS Load Balancer Controller using the command that 
# corresponds to the Region that your cluster is in


helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=${clustername} \
  --set region=${region} \
  --set vpcId=${vpcid} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system

# Create Certificate for use in Managed Endpoint
#certdomain taken from parameters.sh
openssl req -x509 -newkey rsa:1024 \
  -keyout privateKey.pem \
  -out certificateChain.pem -days 365 -nodes \
  -subj "/C=US/ST=Washington/L=Seattle/O=MyOrg/OU=MyDept/CN=${certdomain}"

cp certificateChain.pem trustedCertificates.pem

certjson=$(aws acm import-certificate \
  --certificate fileb://certificateChain.pem \
  --private-key fileb://privateKey.pem \
  --certificate-chain fileb://certificateChain.pem \
  --region ${region})

certarn=$(echo $certjson | jq .CertificateArn | sed 's/"//g')

echo $certarn
echo "----"
echo $execution_role_arn


aws emr-containers create-managed-endpoint \
--type JUPYTER_ENTERPRISE_GATEWAY \
--virtual-cluster-id ${virt_cluster_id} \
--name ${virtendpointname} \
--execution-role-arn ${execution_role_arn} \
--release-label ${emr_release_label} \
--certificate-arn ${certarn} \
--region ${region} \
--configuration-overrides '{
    "applicationConfiguration": [
      {
        "classification": "spark-defaults",
        "properties": {
          "spark.driver.cores":"2",
          "spark.driver.memory":"8G",
          "spark.driver.maxResultSize":"2gb",
          "spark.executor.instances":"3",
          "spark.executor.cores":"5",
          "spark.executor.memory":"16G",
          "spark.executor.memoryOverhead":"2G",
          "spark.hadoop.hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
          "spark.sql.catalogImplementation": "hive",
          "spark.dynamicAllocation.enabled":"false",
          "spark.pyspark.driver.python":"/opt/venv/bin/python3",
          "spark.pyspark.python": "/opt/venv/bin/python3"

        }
      },
      {
        "classification": "jupyter-kernel-overrides",
        "configurations": [
          {
             "classification": "python3",
             "properties": {
               "container-image": "public.ecr.aws/o7d8v7g9/emr-eks-cpu-transformers-notebook-6.13.0:0.4"
             }
          },
          {
             "classification": "spark-python-kubernetes",
             "properties": {
               "container-image": "public.ecr.aws/o7d8v7g9/emr-eks-cpu-transformers-notebook-6.13.0:0.4"
             }
          }
        ]
      }
    ]
  }'
