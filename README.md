# Guidance for Scaling Electronic Design Automation (EDA) on AWS

## Table of Content (required)

List the top-level sections of the README template, along with a hyperlink to the specific section.

### Required

1. [Overview](#overview-required)
    - [Archiecture](#reference-architecture)
    - [Cost](#cost)
2. [Prerequisites](#prerequisites-required)
    - [Operating System](#operating-system-required)
3. [Deployment Steps](#deployment-steps-required)
4. [Deployment Validation](#deployment-validation-required)
5. [Running the Guidance](#running-the-guidance-required)
6. [Next Steps](#next-steps-required)
7. [Cleanup](#cleanup-required)

***Optional***

8. [FAQ, known issues, additional considerations, and limitations](#faq-known-issues-additional-considerations-and-limitations-optional)
9. [Revisions](#revisions-optional)
10. [Notices](#notices-optional)
11. [Authors](#authors-optional)

## Overview (required)

This Guidance demonstrates how to implement a cloud-bursting solution that seamlessly extends your on-premises semiconductor workflows to the cloud. It allows you to run hybrid or entirely cloud-based semiconductor design and verification workflows on AWS while utilizing your existing on-premises chip design environments based on IBM Spectrum Load Sharing Facility (LSF) and NetApp storage.

### Reference Architecture
![Architecture Diagram](assets/images/Cloud-Scale-Architecture.png)


### Cost

You are responsible for the cost of the AWS services used while running this Guidance. As of month, the cost for running this Guidance with the default settings in the AWS Region(us-west-2) is approximately $1,556 per month for deploying EDA infrastrcuture(2 of IBM Spectrum LSF Primary Server, 2 of NICE DCV Login Server, 2 of FSx for Netapp ONTAP file system)


### Sample Cost Table


The following table provides a sample cost breakdown for deploying this Guidance with the default parameters in the US West (Orego) Region for one month.

| AWS service  | Dimensions | Cost [USD] |
| ----------- | ------------ | ------------ |
| Amazon EC2(m5.2xlarge) | IBM Specturm LSF Primary servers(2)  | $560.64 month |
| Amazon EC2(m5.xlarge) | NICE DCV Login servers(2) | $280.32month |
| FSx for Netapp ONTAP | 2 File Systems |  $638.76month |
| Transit Gateway| Peering two VPC | $77.00month |

## Prerequisites
The following is requred to run this guidance.

1. An AWS account with administrativie level access
2. License/Full Linux(x86 and aarch64) distribution packages for IBM Spectrum LSF 10.1
3. A free subscription to the [Official CentOS 7 x86_64 HVM AMI](https://aws.amazon.com/marketplace/pp/B00O7WM7QW)
4. Amazon EC2 Key Pair

### Operating System 
This guidance based on two linux system(CentOS 7 and Amazon Linux 2)for deploying the EDA environment.

#### 1. Obtain IBM Spectrum LSF Software

The IBM Spectrum LSF software is not provided in this workshop; you will need to download LSF 10.1 Fix Pack 8 or later and an associated entitlement file from your IBM Passport Advantage portal to complete this tutorial. See the details [Third-part tools](#third-party-tools)

#### 2. Download NICE DCV Remote Desktop Client

**NICE DCV** is a license-free, high-performance remote display protocol that you'll use for logging into the login server's desktop environment. Download and install the [NICE DCV remote desktop native client](https://download.nice-dcv.com/) on the computer you will be using for this workshop.

#### 3. Prepare AWS Account

If you don’t already have an AWS account, create one at [aws.amazon.com](https://aws.amazon.com/) by following the on-screen instructions. Part of the sign-up process involves receiving a phone call and entering a PIN using the phone keypad. Your AWS account is automatically signed up for all AWS services. You are charged only for the services you use.
s
Before you launch this tutorial, your account must be configured as specified below. Otherwise, the deployment might fail.

Sign in to your AWS account at [https://aws.amazon.com/](https://aws.amazon.com) with an IAM user role that includes full administrative permissions.



### Third-party tools
Download the following packages from IBM:

| **Kind**          | **IBM Download Source** | **Description** | **Package Name**                                   |
| ----------------- | ----------------------- | --------------- | -------------------------------------------------- |
| Install Script    | Passport Advantage      | \--             | lsf10.1_lsfinstall_linux_x86_64.tar.Z              |
| Base Distribution(x86) | Passport Advantage | \--             | lsf10.1_linux2.6-glibc2.3-x86_64.tar.Z             |
| Base Distribution(arm64) | Passport Advantage | \--           | lsf10.1_lnx312-lib217-armv8.tar.Z                  |
| Entitlement File  | Passport Advantage      | \--             | lsf_std_entitlement.dat or lsf_adv_entitlement.dat |
| Fix Pack(x86)     | Passport Advantage      | \--             | lsf10.1_linux2.6-glibc2.3-x86_64-601547.tar.Z      |
| Fix Pack(arm64)   | Passport Advantage      | \--             | lsf10.1_lnx312-lib217-armv8-601547.tar.Z           |


### AWS account requirements (If applicable)

*List out pre-requisites required on the AWS account if applicable, this includes enabling AWS regions, requiring ACM certificate.*

**Example:** “This deployment requires you have public ACM certificate available in your AWS account”

**Example resources:**
- ACM certificate 
- DNS record
- S3 bucket
- VPC
- IAM role with specific permissions
- Enabling a Region or service etc.


### aws cdk bootstrap (if sample code has aws-cdk)

<If using aws-cdk, include steps for account bootstrap for new cdk users.>

**Example blurb:** “This Guidance uses aws-cdk. If you are using aws-cdk for first time, please perform the below bootstrapping....”

### Service limits  (if applicable)

<Talk about any critical service limits that affect the regular functioning of the Guidance. If the Guidance requires service limit increase, include the service name, limit name and link to the service quotas page.>

### Supported Regions (if applicable)

<If the Guidance is built for specific AWS Regions, or if the services used in the Guidance do not support all Regions, please specify the Region this Guidance is best suited for>


## Deployment Steps (required)

Deployment steps must be numbered, comprehensive, and usable to customers at any level of AWS expertise. The steps must include the precise commands to run, and describe the action it performs.

* All steps must be numbered.
* If the step requires manual actions from the AWS console, include a screenshot if possible.
* The steps must start with the following command to clone the repo. ```git clone xxxxxxx```
* If applicable, provide instructions to create the Python virtual environment, and installing the packages using ```requirement.txt```.
* If applicable, provide instructions to capture the deployed resource ARN or ID using the CLI command (recommended), or console action.

 
**Example:**

1. Clone the repo using command ```git clone xxxxxxxxxx```
2. cd to the repo folder ```cd <repo-name>```
3. Install packages in requirements using command ```pip install requirement.txt```
4. Edit content of **file-name** and replace **s3-bucket** with the bucket name in your account.
5. Run this command to deploy the stack ```cdk deploy``` 
6. Capture the domain name created by running this CLI command ```aws apigateway ............```



## Deployment Validation  (required)

<Provide steps to validate a successful deployment, such as terminal output, verifying that the resource is created, status of the CloudFormation template, etc.>


**Examples:**

* Open CloudFormation console and verify the status of the template with the name starting with xxxxxx.
* If deployment is successful, you should see an active database instance with the name starting with <xxxxx> in        the RDS console.
*  Run the following CLI command to validate the deployment: ```aws cloudformation describe xxxxxxxxxxxxx```



## Running the Guidance (required)

<Provide instructions to run the Guidance with the sample data or input provided, and interpret the output received.> 

This section should include:

* Guidance inputs
* Commands to run
* Expected output (provide screenshot if possible)
* Output description



## Next Steps (required)

Provide suggestions and recommendations about how customers can modify the parameters and the components of the Guidance to further enhance it according to their requirements.


## Cleanup (required)

- Include detailed instructions, commands, and console actions to delete the deployed Guidance.
- If the Guidance requires manual deletion of resources, such as the content of an S3 bucket, please specify.



## FAQ, known issues, additional considerations, and limitations (optional)


**Known issues (optional)**

<If there are common known issues, or errors that can occur during the Guidance deployment, describe the issue and resolution steps here>


**Additional considerations (if applicable)**

<Include considerations the customer must know while using the Guidance, such as anti-patterns, or billing considerations.>

**Examples:**

- “This Guidance creates a public AWS bucket required for the use-case.”
- “This Guidance created an Amazon SageMaker notebook that is billed per hour irrespective of usage.”
- “This Guidance creates unauthenticated public API endpoints.”


Provide a link to the *GitHub issues page* for users to provide feedback.


**Example:** *“For any feedback, questions, or suggestions, please use the issues tab under this repo.”*

## Revisions (optional)

Document all notable changes to this project.

Consider formatting this section based on Keep a Changelog, and adhering to Semantic Versioning.

## Notices (optional)

Include a legal disclaimer

**Example:**
*Customers are responsible for making their own independent assessment of the information in this Guidance. This Guidance: (a) is for informational purposes only, (b) represents AWS current product offerings and practices, which are subject to change without notice, and (c) does not create any commitments or assurances from AWS and its affiliates, suppliers or licensors. AWS products or services are provided “as is” without warranties, representations, or conditions of any kind, whether express or implied. AWS responsibilities and liabilities to its customers are controlled by AWS agreements, and this Guidance is not part of, nor does it modify, any agreement between AWS and its customers.*


## Authors (optional)

Name of code contributors
