output "ec2_public_ip" {
    value = [
        for instance in aws_instance.terra-ec2 : instance.public_ip
    ]
  
}