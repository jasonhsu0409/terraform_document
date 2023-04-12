// Create lauch template
resource "aws_launch_template" "example" {
  name_prefix          = "example-template"
  image_id             = var.ami
  instance_type        = var.type
  key_name             = var.key
  vpc_security_group_ids = [aws_security_group.web.id]  
  iam_instance_profile {
     name = "ec2-acces-s3"
  }
  // Launch template userdata have to read with base64encode
  user_data = base64encode(<<EOF
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
sudo sh -c "echo '{
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
            "log_group_name": "jason-access-log",
            "log_stream_name": "{instance_id}",
            "retention_in_days": -1
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
      "collectd": {
        "metrics_aggregation_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ],
        "totalcpu": false
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}' > /opt/aws/amazon-cloudwatch-agent/bin/config.json"
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo systemctl restart amazon-cloudwatch-agent
sudo yum install -y amazon-efs-utils
sudo mkdir -p /usr/bin/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.example.dns_name}:/ /usr/bin/efs 
EOF
    )
}

// Create autoscaling_group
resource "aws_autoscaling_group" "example" {
  name  = "example-asg"
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  target_group_arns    = [aws_lb_target_group.example.arn]
  vpc_zone_identifier  = [aws_subnet.private[0].id,aws_subnet.private[1].id]
  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
  // Ensure instance is create after efs, so we can correctly mount efs to instance 
  depends_on = [
   time_sleep.wait_efs
  ]
} 




