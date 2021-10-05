#######################################################
#####      ECS - IAM Role
#######################################################
resource "aws_iam_role" "ecs_task_role" {
    name               = "ecs-task-role"
    description        = "A custom IAM role used by ECS tasks"
    assume_role_policy = "${file("./iam/ecs_role.json")}"

    tags = {
      env  = "dev"
      name = "ecs-task-role"
  }
}

#######################################################
#####      ECS -  IAM Policy
#######################################################
resource "aws_iam_policy" "ecs_task_policy" {
    name        = "ecs-task-policy"
    description = "A custom IAM policy used by ECS tasks"
    policy      = "${file("./iam/ecs_policy.json")}"

    tags = {
        env  = "dev"
        name = "ecs-task-policy"
    }
}

#######################################################
#####      ECS - Role Policy Attachement
#######################################################
resource "aws_iam_policy_attachment" "ecs_task_role_policy_attachment" {
    name       = "ecs-task-role-policy-attachment"
    roles      = [aws_iam_role.ecs_task_role.name]
    policy_arn = aws_iam_policy.ecs_task_policy.arn
}
