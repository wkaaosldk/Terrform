resource "aws_autoscaling_group" "example" {
  name                      = "test"
  max_size             = var.max_size
  min_size             = var.min_size
  health_check_grace_period = 200 #인스턴스 시작후 상태 유예기간 설정
 # health_check_type         = "ELB"   # ELB(Elastic Load Balancer)를 사용한 상태 확인 방식 설정
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = [var.public_subnet_id_1, var.public_subnet_id_2]


  # target_group_arns를 사용해 ALB 대상 그룹과 연결
  target_group_arns = [var.alb_target_group_arn]

launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"  # 항상 최신 버전의 템플릿 사용
  }

tag {
  key                 = "Environment"
  value               = "test"
  propagate_at_launch = true  # 새로 생성된 인스턴스에 태그 적용
}

}

resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.security_group_id]
  key_name = var.key_name
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up_policy"
  scaling_adjustment      = 1  # 인스턴스 1개를 추가
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300  # 5분 동안 쿨다운 설정 (조정 간격)
  autoscaling_group_name  = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down_policy"
  scaling_adjustment      = -1  # 인스턴스 1개를 줄임
  adjustment_type         = "ChangeInCapacity" # 변경되는 용량을 기준으로 조정합니다. 
#여기서는 인스턴스 개수를 scaling_adjustment 값에 따라 줄임을 의미한다.
  cooldown                = 300
  autoscaling_group_name  = aws_autoscaling_group.example.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanThreshold" # 비교 연산자 
  evaluation_periods  = 1 # 이 알람이 트리거되기 전, 지표가 임계값을 초과하는 기간을 정의합니다. 
  #2로 설정되어 있으므로, 2번의 평가 주기 동안 임계값을 초과하면 알람이 발생합니다.
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # 2분마다 메트릭을 모니터링한다.
  statistic           = "Average"
  threshold           = 70  # CPU 사용률 70% 초과 시
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn] # 위에 scale up 작업이 수행된다.
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name # 이 알람이 적용될 리소스를 지정
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20  # CPU 사용률 20% 미만 시
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name 
  }
}

