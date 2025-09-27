###############################################
# GuardDuty detector
###############################################
module "guardduty_detector" {                      
  for_each = var.enabled ? { primary = true } : {} 
  source   = "aws-ia/guardduty/aws"                
  version  = "~> 0.1"                              

  replica_region                = var.replica_region                # レプリカ用のリージョン設定
  enable_guardduty              = var.enable_guardduty              # GuardDuty 自体を有効化するか
  enable_s3_protection          = var.enable_s3_protection          # S3 保護の有効／無効
  enable_rds_protection         = var.enable_rds_protection         # RDS 保護の有効／無効
  enable_lambda_protection      = var.enable_lambda_protection      # Lambda 保護の有効／無効
  enable_malware_protection     = var.enable_malware_protection     # マルウェア対策データソースの有効／無効
  enable_kubernetes_protection  = var.enable_kubernetes_protection  # Kubernetes 保護の有効／無効
  enable_eks_runtime_monitoring = var.enable_eks_runtime_monitoring # EKS ランタイム監視の有効／無効
  enable_ecs_runtime_monitoring = var.enable_ecs_runtime_monitoring # ECS ランタイム監視の有効／無効
  enable_ec2_runtime_monitoring = var.enable_ec2_runtime_monitoring # EC2 ランタイム監視の有効／無効
  enable_snapshot_retention     = var.enable_snapshot_retention     # マルウェア検出時の EBS スナップショット保持を設定

  manage_eks_addon = var.manage_eks_addon # GuardDuty EKS アドオンをモジュールで管理するか
  manage_ecs_agent = var.manage_ecs_agent # GuardDuty ECS エージェントをモジュールで管理するか
  manage_ec2_agent = var.manage_ec2_agent # GuardDuty EC2 エージェントをモジュールで管理するか

  finding_publishing_frequency   = var.finding_publishing_frequency   # 検出結果の通知頻度
  malware_resource_protection    = var.malware_resource_protection    # マルウェア保護対象リソースのリスト
  create_malware_protection_role = var.create_malware_protection_role # マルウェア保護用のサービスリンクドロール作成可否

  publish_to_s3        = var.publish_to_s3        # 検出結果を S3 に出力するか
  guardduty_s3_bucket  = var.guardduty_s3_bucket  # 既存の GuardDuty バケット名
  guardduty_bucket_acl = var.guardduty_bucket_acl # GuardDuty バケットに適用する ACL
  publishing_config    = var.publishing_config    # 出力先の詳細設定

  filter_config         = var.filter_config         # 検出結果を絞り込むフィルタ設定
  ipset_config          = var.ipset_config          # 信頼済み IP セットの設定
  threatintelset_config = var.threatintelset_config # 脅威インテルセットの設定

  tags = local.merged_tags 
}

###############################################
# Organizations delegated administrator
###############################################
module "organizations_admin" {                                                      
  for_each = var.enabled && var.enable_organization_admin ? { primary = true } : {} 
  source   = "aws-ia/guardduty/aws//modules/organizations_admin"                    
  version  = "~> 0.1"                                                               

  admin_account_id                 = local.delegated_admin_account_id                           # 委任管理者アカウント ID
  guardduty_detector_id            = module.guardduty_detector["primary"].guardduty_detector.id # 先に作成した検出器の ID
  auto_enable_organization_members = var.auto_enable_organization_members                       # メンバー自動有効化モード
  auto_enable_org_config           = var.auto_enable_org_config                                 # 組織設定の自動有効化

  enable_s3_protection          = var.enable_s3_protection          # 組織単位で S3 保護を適用
  enable_rds_protection         = var.enable_rds_protection         # 組織単位で RDS 保護を適用
  enable_lambda_protection      = var.enable_lambda_protection      # 組織単位で Lambda 保護を適用
  enable_kubernetes_protection  = var.enable_kubernetes_protection  # 組織単位で Kubernetes 保護を適用
  enable_malware_protection     = var.enable_malware_protection     # 組織単位でマルウェア保護を適用
  enable_eks_runtime_monitoring = var.enable_eks_runtime_monitoring # 組織単位で EKS 監視を適用
  enable_ecs_runtime_monitoring = var.enable_ecs_runtime_monitoring # 組織単位で ECS 監視を適用
  enable_ec2_runtime_monitoring = var.enable_ec2_runtime_monitoring # 組織単位で EC2 監視を適用

  manage_eks_addon = var.manage_eks_addon # EKS アドオン管理の委任を有効化
  manage_ecs_agent = var.manage_ecs_agent # ECS エージェント管理の委任を有効化
  manage_ec2_agent = var.manage_ec2_agent # EC2 エージェント管理の委任を有効化
}
