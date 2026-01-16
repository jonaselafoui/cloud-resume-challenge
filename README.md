# ☁️ Cloud Resume Challenge (AWS)

This repository contains my implementation of the **Cloud Resume Challenge** using **AWS** and **Terraform**.  
The project demonstrates a complete, serverless, production-ready cloud architecture with Infrastructure as Code and CI/CD.
The active website can be found on [jonas.ma](https://jonas.ma)

---

## 📌 Project Overview

The Cloud Resume Challenge is designed to validate real-world cloud engineering skills by building and deploying a resume website using cloud-native services.

This implementation includes:
- A static resume website hosted on AWS
- A serverless backend for a visitor counter
- A NoSQL database for persistence
- Infrastructure fully defined with Terraform
- Automated CI/CD using AWS CodeBuild and GitHub

---

## 🏗 Architecture

<p align="center">
  <img src="website/images/drawio.png" width="800">
</p>

### Architecture Flow

1. Users access the resume website via HTTPS
2. Requests are routed through **Amazon CloudFront**
3. Static content is served from an **S3 bucket**
4. Visitor counter requests are forwarded to **API Gateway**
5. API Gateway invokes an **AWS Lambda** function
6. The Lambda function reads/writes the visitor count in **DynamoDB**

---

## 🚀 AWS Services Used

### Frontend
- **Amazon S3** – Static website hosting
- **Amazon CloudFront** – CDN, HTTPS, caching

### Backend
- **Amazon API Gateway** – REST API endpoint
- **AWS Lambda** – Serverless backend logic

### Database
- **Amazon DynamoDB** – Visitor counter storage

### CI/CD
- **AWS CodeBuild** – Build and deployment automation
- **GitHub** – Source control

### Infrastructure as Code
- **Terraform**
  - Modular structure
  - Reusable components
  - Fully reproducible infrastructure

---

## 📂 Repository Structure

```
.
├── terraform/
│   ├── main.tf
│   └── modules/
│       ├── apigw/
│       ├── cloudfront/
│       ├── codebuild/
│       ├── dynamodb/
│       ├── iam/
│       ├── lambda/
│       └── s3/
├── website/
│   ├── index.html
│   └── images/
├── overview.drawio
└── README.md
```

---

## 🔁 CI/CD Pipeline

The CI/CD pipeline is implemented using **AWS CodeBuild** and performs:

1. Source checkout from GitHub
2. Terraform initialization and validation
3. Infrastructure deployment
4. Frontend upload to S3
5. Backend deployment (Lambda + API Gateway)

---

## 🧪 Testing

- Manual end-to-end testing via browser
- Terraform validation during CI/CD
- API tested via browser and direct HTTP requests

---

## 🔒 Security Considerations

- HTTPS enforced via CloudFront
- IAM roles follow least-privilege principle
- No secrets committed to the repository
- Backend accessible only via API Gateway

---

## 📈 Future Improvements

- Custom domain with ACM certificate
- CloudWatch monitoring and alarms
- Automated API tests
- Terraform state backend with locking
- WAF integration

---

## 🙌 Acknowledgements

This project is based on the **Cloud Resume Challenge** created by Forrest Brazeal.

---

## 📬 Contact

Feel free to open an issue or reach out if you have feedback or questions.
