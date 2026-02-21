output "ec2_public_ip" {
    value = [
        for instance in aws_instance.terra-ec2 : {
            name = instance.tags.Name
            public_ip = instance.public_ip
            }
    ]
}