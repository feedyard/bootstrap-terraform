from invoke import task
import json
import boto3
from os.path import expanduser

@task
def new(ctx):
    ctx.run("terraform init -var-file=./bootstrap.tfvars", pty=True)
    ctx.run("terraform workspace new bootstrap", pty=True)

@task
def init(ctx):
    ctx.run("terraform init -var-file=./bootstrap.tfvars", pty=True)
    ctx.run("terraform workspace select bootstrap", pty=True)

@task
def test(ctx):
    ctx.run("bundle exec rspec spec", pty=True)

@task
def plan(ctx):
    ctx.run("terraform get", pty=True)
    ctx.run("terraform plan -var-file=./bootstrap.tfvars", pty=True)

@task
def apply(ctx):
    ctx.run("terraform apply -var-file=./bootstrap.tfvars", pty=True)

@task
def prep(ctx):
    tfvars = json.loads(open('./bootstrap.tfvars').read())
    docker_machine_create = 'docker-machine create --driver generic ' \
                            '--generic-ip-address {0} ' \
                            '--generic-ssh-user {1} ' \
                            '--generic-ssh-key {2} ' \
                            '{3}'

    host_name = public_dns_name(tfvars)

    if host_name:
        cmd = docker_machine_create.format(host_name,
                                           tfvars['bootstrap-instance-user'],
                                           tfvars['bootstrap-instance-pem-file'],
                                           tfvars['bootstrap-instance-name'])
        ctx.run(cmd, pty=True)
    else:
        not_found(tfvars['bootstrap-instance-name'])

@task
def swarm(ctx):
    tfvars = json.loads(open('./bootstrap.tfvars').read())
    host_name = public_dns_name(tfvars)

    if host_name:
        cmd = docker_remote(tfvars, host_name) + "swarm init"
        ctx.run(cmd, pty=True)
    else:
        not_found(tfvars['bootstrap-instance-name'])

@task
def secrets(ctx):
    tfvars = json.loads(open('./bootstrap.tfvars').read())
    host_name = public_dns_name(tfvars)

    if host_name:
        key_path = expanduser("~") + '/.docker/machine/machines/{}/'.format(tfvars['bootstrap-instance-name'])
        pems = ['ca.pem', 'cert.pem', 'key.pem']
        for pem in pems:
            cmd = docker_remote(tfvars, host_name) + "secret create --label env=bootstrap --label node={0} {1} {2}".format(host_name,
                                                                                                                           pem,
                                                                                                                           key_path + pem)
            ctx.run(cmd, pty=True)
    else:
        not_found(tfvars['bootstrap-instance-name'])


def public_dns_name(tfvars):
    ec2 = boto3.client('ec2')

    response = ec2.describe_instances(Filters=[
        {'Name':'tag:Name', 'Values':[tfvars['bootstrap-instance-name']]},
        {'Name': 'instance-state-name', 'Values': ['running']}])

    if response['Reservations']:
        return(response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicDnsName'])
    else:
        return false

def docker_remote(tfvars, host_name):
    key_path = expanduser("~") + '/.docker/machine/machines/{}/'.format(tfvars['bootstrap-instance-name'])
    return "docker --tlsverify --tlscacert={} --tlscert={} --tlskey={} -H={} ".format(key_path + 'ca.pem',
                                                                                      key_path + 'cert.pem',
                                                                                      key_path + 'key.pem',
                                                                                      host_name + ':2376')

def not_found(host_name):
    print('instance:{} not found'.format(host_name))