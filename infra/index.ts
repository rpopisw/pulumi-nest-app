import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

const config = new pulumi.Config();
const containerPort = config.getNumber("containerPort") || 80;
const cpu = config.getNumber("cpu") || 512;
const memory = config.getNumber("memory") || 128;

// An ECS cluster to deploy into
const cluster = new aws.ecs.Cluster("cluster-1", {});

// An ALB to serve the container endpoint to the internet
const loadbalancer = new awsx.lb.ApplicationLoadBalancer("loadbalancer-1", {});

// An ECR repository to store our application's container image
const repo = new awsx.ecr.Repository("repo-1", {
    forceDelete: true,
});

// Build and publish our application's container image from ./app to the ECR repository
const image = new awsx.ecr.Image("image-1", {
    repositoryUrl: repo.url,
    path: "..",
});

// Deploy an ECS Service on Fargate to host the application container
const service = new awsx.ecs.FargateService("service-1", {
    cluster: cluster.arn,
    assignPublicIp: true,
    taskDefinitionArgs: {
        container: {
            image: image.imageUri,
            cpu: cpu,
            memory: memory,
            essential: true,
            portMappings: [{
                containerPort: containerPort,
                targetGroup: loadbalancer.defaultTargetGroup,
            }],
        },
    },
});

// The URL at which the container's HTTP endpoint will be available
export const url = pulumi.interpolate`http://${loadbalancer.loadBalancer.dnsName}`;