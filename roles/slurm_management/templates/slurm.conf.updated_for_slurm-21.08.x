ClusterName={{ slurm_cluster_name }}
SlurmctldHost={{ hostvars[groups['sys_admin_interface'][0]]['ansible_hostname'] }}
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurm
SlurmdSpoolDir=/var/spool/slurmd
SwitchType=switch/none
MpiDefault=none
MpiParams=ports=12000-12999
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmdPidFile=/var/run/slurm/slurmd.pid
ProctrackType=proctrack/cgroup
ReturnToService=1
TaskPlugin=task/affinity,task/cgroup
JobSubmitPlugins=lua
TmpFS=/local
# Terminate job immediately when one of the processes is crashed or aborted.
KillOnBadExit=1
# Automatically requeue jobs after a node failure or preemption by a higher prio job.
JobRequeue=1
#
# Prologs and Epilogs.
#
PrologFlags=Alloc
Prolog=/etc/slurm/slurm.prolog
Epilog=/etc/slurm/slurm.epilog*
TaskProlog=/etc/slurm/slurm.taskprolog
#TaskEpilog=/etc/slurm/slurm.taskepilog
#
# Timers
#
SlurmctldTimeout=300
SlurmdTimeout=300
MessageTimeout=60
GetEnvTimeout=20
BatchStartTimeout=30
InactiveLimit=0
MinJobAge=300
KillWait=30
UnkillableStepTimeout=180
Waittime=15
#
# Scheduling
#
SchedulerType=sched/backfill
SchedulerParameters=kill_invalid_depend,bf_continue,bf_max_job_test=10000,bf_max_job_user=5000,default_queue_depth=1000,bf_window=10080,bf_resolution=300,bf_busy_nodes,preempt_reorder_count=100,preempt_youngest_first
SelectType=select/cons_res
SelectTypeParameters=CR_Core_Memory
PriorityType=priority/multifactor
PriorityDecayHalfLife=3-0
PriorityFavorSmall=NO
PriorityWeightAge=1000
PriorityWeightFairshare=100000
PriorityWeightJobSize=0
PriorityWeightPartition=0
PriorityWeightQOS=1000000
PriorityMaxAge=14-0
PriorityFlags=FAIR_TREE,MAX_TRES
PreemptType=preempt/qos
PreemptMode=REQUEUE
#
# Logging
#
SlurmctldDebug=3  # 3 == info (default)
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=3  # 3 == info (default)
SlurmdLogFile=/var/log/slurm/slurmd.log
JobCompType=jobcomp/filetxt
JobCompLoc=/var/log/slurm/slurm.jobcomp
#
# Email notifications
#
# Disable sending of email notifications, because it may cause a spam flood,
# when thousands of scripts with the same bug crash shortly after another.
# We also don't want jobs to fail when email notifications were requested,
# so therefore we alias the mail program to /bin/true
#
MailProg=/bin/true
#
# Accounting
#
# Note: Users and their associations must be in the accounting database to make fair share work.
#
JobAcctGatherType=jobacct_gather/linux
JobAcctGatherParams=UsePss,NoOverMemoryKill
AccountingStorageEnforce=limits,qos  # Will also enable: associations
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost={{ hostvars[groups['sys_admin_interface'][0]]['ansible_hostname'] }}
MaxJobCount=100000
#
# Node Health Check (NHC)
#
HealthCheckProgram=/usr/sbin/nhc
HealthCheckInterval=300
#
# Partitions
#
EnforcePartLimits=Any
PartitionName=DEFAULT State=UP DefMemPerCPU=1024 MaxNodes=1 MaxTime=7-00:00:01
{% for partition in slurm_partitions %}
PartitionName={{ partition.name }} Default={{ partition.default }} Nodes={{ partition.nodes }} MaxNodes={{ partition.max_nodes_per_job }} MaxCPUsPerNode={{ partition.max_cores_per_node }} MaxMemPerNode={{ partition.max_mem_per_node }} {{ partition.extra_options }}
{% endfor %}
#
# Compute nodes
#
{% for node in groups['compute_vm'] %}
NodeName={{ node }} Sockets={{ hostvars[node]['slurm_sockets'] }} CoresPerSocket={{ hostvars[node]['slurm_cores_per_socket'] }} ThreadsPerCore=1 State=UNKNOWN RealMemory={{ hostvars[node]['slurm_real_memory'] }} TmpDisk={{ hostvars[node]['slurm_local_disk'] | default(0, true) }} Feature={{ hostvars[node]['slurm_features'] }}
{% endfor %}
#
# User Interface nodes (only for data staging jobs).
#
{% for node in groups['user_interface'] %}
NodeName={{ node }} Sockets={{ hostvars[node]['slurm_sockets'] }} CoresPerSocket={{ hostvars[node]['slurm_cores_per_socket'] }} ThreadsPerCore=1 State=UNKNOWN RealMemory={{ hostvars[node]['slurm_real_memory'] }} TmpDisk={{ hostvars[node]['slurm_local_disk'] | default(0, true) }} Feature={{ hostvars[node]['slurm_features'] }}
{% endfor %}
