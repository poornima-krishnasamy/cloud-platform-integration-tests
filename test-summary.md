How to test KIAM
To check assume role and the pod can run with the assume_role
    create a iam role
    create a assume role policy for that role
    create a policy to access aws s3 using api
    create a script which will list s3 bukets / what other actions that can be performed?
    run the docker image of the script in a pod in a test namespace
    check whether kiam assume role and execute the script inside a pod 
To check kiam 