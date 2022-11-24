output "web_instance_ip" {
    value = aws_instance.native_linux.public_ip
}
