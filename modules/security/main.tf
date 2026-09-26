
#  Security Group Definition
resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${each.value.name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each = var.ingress_sg_rules

  security_group_id = aws_security_group.this[each.value.security_group].id

  # Source can be either CIDR or another SG
  cidr_ipv4 = each.value.rule_type == "cidr" ? each.value.cidr : null

  referenced_security_group_id = (
    each.value.rule_type == "sg" ?
    aws_security_group.this[each.value.source_security_group].id :
    null
  )

  from_port   = each.value.port
  ip_protocol = each.value.protocol
  to_port     = each.value.port

}

resource "aws_vpc_security_group_egress_rule" "this" {
 for_each = var.egress_sg_rules

  security_group_id = aws_security_group.this[each.value.security_group].id

  cidr_ipv4 = (
    each.value.rule_type == "cidr" ?
    each.value.cidr :
    null
  )

  referenced_security_group_id = (
    each.value.rule_type == "sg" ?
    aws_security_group.this[each.value.destination_security_group].id :
    null
  )

  ip_protocol = each.value.protocol

  from_port = each.value.protocol == "-1" ? null : each.value.from_port
  to_port   = each.value.protocol == "-1" ? null : each.value.to_port
}
