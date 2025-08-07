import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    s3 = boto3.client('s3')

    # Parar instâncias EC2
    instances = ec2.describe_instances()
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            ec2.stop_instances(InstanceIds=[instance_id])

    # Deletar buckets S3
    buckets = s3.list_buckets()
    for bucket in buckets['Buckets']:
        bucket_name = bucket['Name']
        try:
            s3.delete_bucket(Bucket=bucket_name)
        except Exception as e:
            print(f"Erro ao deletar bucket {bucket_name}: {e}")

    return {
        'statusCode': 200,
        'body': 'Recursos encerrados com sucesso!'
    }
