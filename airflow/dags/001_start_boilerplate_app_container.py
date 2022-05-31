#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

"""
###  start_boilerplate_app_container
Maintainer: Viacheslav Kolupaev
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.operators.bash import BashOperator
from airflow.providers.docker.operators.docker import DockerOperator

with DAG(
    dag_id='001_start_boilerplate_app_container',
    description='DAG to run Docker container with boilerplate app.',
    schedule_interval=timedelta(days=1),
    timetable=None,
    start_date=None,
    end_date=None,
    # These args will get passed on to each operator
    # You can override them on a per-task basis during operator initialization
    default_args={
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
        # 'queue': 'bash_queue',
        # 'pool': 'backfill',
        # 'priority_weight': 10,
        # 'end_date': datetime(2016, 1, 1),
        # 'wait_for_downstream': False,
        # 'sla': timedelta(hours=2),
        # 'execution_timeout': timedelta(seconds=300),
        # 'on_failure_callback': some_function,
        # 'on_success_callback': some_other_function,
        # 'on_retry_callback': another_function,
        # 'sla_miss_callback': yet_another_function,
        # 'trigger_rule': 'all_success'
    },
    dagrun_timeout=None,
    catchup=False,
    doc_md=None,
    params=None,
    tags=['vkolupaev', 'docker', 'boilerplate'],


) as dag:
    dag.doc_md = __doc__  # providing that you have a docstring at the beginning of the DAG

    # Getting environment variables.
    private_environment = {
        'APP_API_ACCESS_HTTP_BEARER_TOKEN': Variable.get(
            key='APP_API_ACCESS_HTTP_BEARER_TOKEN',
            default_var=None,
            deserialize_json=False,
        ),
        'DB_PASSWORD': Variable.get(
            key='DB_PASSWORD',
            default_var=None,
            deserialize_json=False,
        ),
    }
    non_private_environment = {
        'APP_ENV_STATE': Variable.get(
            key='APP_ENV_STATE',
            default_var=None,
            deserialize_json=False,
        ),
        'DB_USER': Variable.get(
            key='DB_USER',
            default_var=None,
            deserialize_json=False,
        ),
        'IS_DEBUG': Variable.get(
            key='IS_DEBUG',
            default_var=None,
            deserialize_json=False,
        ),
    }
    all_environment = private_environment
    all_environment |= non_private_environment

    # t1, t2 and t3 are examples of tasks created by instantiating operators

    # OPTION 1.
    # Running a container using a bash script.
    t1 = BashOperator(
        task_id='t1_start_boilerplate_app_container',
        depends_on_past=False,
        dag=dag,
        bash_command='bash_scripts/001_start_boilerplate_app_container.sh',
        env=all_environment,
        append_env=False,
    )

    # OPTION 2.
    # Running a container using `airflow.providers.docker.operators.docker`.
    # There is no argument to publish a container on some port.
    t2 = DockerOperator(
        task_id='docker_run',
        depends_on_past=False,
        trigger_rule='always',
        dag=dag,
        image='boilerplate:latest',
        api_version='auto',
        command=None,
        container_name='boilerplate',
        cpus=0.5,
        # Default for Linux = 'unix:///var/run/docker.sock'
        # Check: `curl --unix-socket /var/run/docker.sock http:/localhost/version`
        docker_url='unix:///var/run/docker.sock',
        environment=non_private_environment,
        private_environment=private_environment,
        force_pull=False,
        mem_limit='200m',
        host_tmp_dir=None,
        network_mode='boilerplate-net',
        tls_ca_cert=None,
        tls_client_cert=None,
        tls_client_key=None,
        tls_hostname=None,
        tls_ssl_version=None,
        mount_tmp_dir=False,
        tmp_dir='/tmp/airflow',
        user=None,
        mounts=None,
        entrypoint=None,
        working_dir=None,
        xcom_all=False,
        docker_conn_id=None,
        dns=None,
        dns_search=None,
        auto_remove=True,
        shm_size=None,
        tty=False,
        privileged=False,
        cap_add=None,
        retrieve_output=False,
        retrieve_output_path=None,
        device_requests=None,
    )

    t1 >> t2
