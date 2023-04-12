
// Create bastion instance
resource "aws_instance" "bastion" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  security_groups = [ aws_security_group.bastion.id ]
  key_name = var.key
  tags = {
    "Name" = "example-bastion"
  }
}


// Create web instance
resource "aws_instance" "web" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name = var.key
  iam_instance_profile = "ec2-acces-s3" 
  // Set httpd & mysql & cloudwatchagent & efs
  user_data = <<EOF
  #!/bin/bash    
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo yum install -y php
sudo yum install -y php-mysqlnd
sudo yum install -y php-gd
sudo yum install -y php-xml 
sudo sh -c "echo 'My private IP address is: '  $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) > /var/www/html/index.php"
sudo systemctl restart httpd
sudo yum install -y mysql
sudo yum install -y amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent
echo '{
                	"agent": {
                		"metrics_collection_interval": 60,
                		"run_as_user": "root"
                	},
                	"logs": {
                		"logs_collected": {
                			"files": {
                				"collect_list": [
                					{
                						"file_path": "/var/log/httpd/access_log",
                						"log_group_name": "example-accesslog",
                						"log_stream_name": "example-webec2",
                						"retention_in_days": 14
                					}
                				]
                			}
                		}
                	},
                	"metrics": {
                		"aggregation_dimensions": [
                			[
                				"InstanceId"
                			]
                		],
                		"append_dimensions": {
                			"AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
                			"ImageId": "$${aws:ImageId}",
                			"InstanceId": "$${aws:InstanceId}",
                			"InstanceType": "$${aws:InstanceType}"
                		},
                		"metrics_collected": {
                			"disk": {
                				"measurement": [
                					"used_percent"
                				],
                				"metrics_collection_interval": 60,
                				"resources": [
                					"*"
                				]
                			},
                			"mem": {
                				"measurement": [
                					"mem_used_percent"
                				],
                				"metrics_collection_interval": 60
                			}
                		}
                	}
                }' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo systemctl restart amazon-cloudwatch-agent
sudo yum install -y amazon-efs-utils
sudo mkdir -p /usr/bin/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.example.dns_name}:/ /usr/bin/efs
sudo touch /usr/bin/efs/example.txt
EOF
  tags = {
    Name = "example-web"
  }
// Ensure instance is create after efs, so we can correctly mount efs to instance 
depends_on = [
 time_sleep.wait_efs 
]
 
}
 resource "time_sleep" "wait_efs" {
  depends_on = [aws_efs_file_system.example]
  create_duration = "3m"
 }

 


