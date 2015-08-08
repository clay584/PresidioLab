# PresidioLab
Random stuff for the Presidio Engineering Lab

## New User Provisioning
This project takes a user's web form input and calls a Rundeck job from the Rundeck API.  Then Rundeck runs the NewUserProvisioning job which calls out to a domain controller via WinRM and executes the Powershell script which actually creates the user account and emails the user.
