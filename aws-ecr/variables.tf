variable "repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    force_delete         = optional(bool, false)
  }))
}

variable "lifecycle_policy_max_images" {
  description = "Maximum number of untagged images to keep per repository"
  type        = number
  default     = 30
}

variable "lifecycle_policy_tagged_count" {
  description = "Maximum number of tagged images to keep per repository"
  type        = number
  default     = 50
}

variable "encryption_type" {
  description = "Encryption type for repositories (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all repositories"
  type        = map(string)
  default     = {}
}
