module "s3_website" {
  source = "./modules/s3_website"
}

module "codebuild" {
  source      = "./modules/codebuild"
  bucket_name = module.s3_website.bucket_name
  bucket_arn  = module.s3_website.bucket_arn
}

module "codepipeline" {
  source          = "./modules/codepipeline"
  codebuild_arn   = module.codebuild.codebuild_arn
  bucket_arn      = module.s3_website.bucket_arn
  bucket_name     = module.s3_website.bucket_name
  codebuild_name  = module.codebuild.codebuild_name
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = module.s3_website.bucket_domain_name
}

module "route53" {
  source                    = "./modules/route53"
  cloudfront_domain_name    = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}

module "dynamodb" {
  source = "./modules/dynamodb"
}