output "alb_dns_name" {
    value = "App adress => ${aws_lb.mainALB.dns_name}"
}

output "audit_password" {
    value = "Audit Password => ${random_string.secret.result}"
}

