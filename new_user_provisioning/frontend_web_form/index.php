<!DOCTYPE html>
<html>
<head>
        <meta charset=utf-8 />
        <title>Presidio Engineering Lab</title>
<!-- Bootstrap -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
<?php if ($_SERVER['REQUEST_METHOD'] == 'GET') : ?>
<form id="NewUserForm" class="form-horizontal" action="https://register.presidiolab.com:9001/index.php" method="post">
<fieldset>

<!-- Form Name -->
<legend>New User Form</legend>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="Username">Username</label>  
  <div class="col-md-4">
  <input id="Username" name="Username" type="text" placeholder="johndoe" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">Use the same username as your Presidio username if possible</span>  
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="EmailAddress">Email Address</label>  
  <div class="col-md-4">
  <input id="EmailAddress" name="EmailAddress" type="email" placeholder="johndoe@presidio.com" class="form-control input-md" required="" pattern=".+@presidio\.com">
  <span class="help-block">This should be your Presidio email address</span>  
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="FirstName">First Name</label>  
  <div class="col-md-4">
  <input id="FirstName" name="FirstName" type="text" placeholder="John" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">Your first name</span>  
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="LastName">Last Name</label>  
  <div class="col-md-4">
  <input id="LastName" name="LastName" type="text" placeholder="Doe" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">Your last name</span>  
  </div>
</div>

<!-- Select Basic -->
<div class="form-group">
  <label class="col-md-4 control-label" for="Department">Department</label>
  <div class="col-md-4">
    <select id="Department" name="Department" class="form-control">
      <option value="SecureNetworks">SecureNetworks</option>
      <option value="Mobility">Mobility</option>
      <option value="DataCenter">DataCenter</option>
      <option value="Collaboration">Collaboration</option>
    </select>
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="ManagerFN">Manager First Name</label>  
  <div class="col-md-4">
  <input id="ManagerFN" name="ManagerFN" type="text" placeholder="Julie" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">First name of your manager</span>  
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="ManagerLN">Manager Last Name</label>  
  <div class="col-md-4">
  <input id="ManagerLN" name="ManagerLN" type="text" placeholder="Roberts" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">Last name of your manager</span>  
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-4 control-label" for="authtoken">API Key</label>  
  <div class="col-md-4">
  <input id="authtoken" name="authtoken" type="text" placeholder="" class="form-control input-md" required="" pattern="\S+">
  <span class="help-block">API Key which you can get from the Accessing the Presidio Lab document on the Presidio Sharepoint.</span>  
  </div>
</div>

<input type="hidden" name="argString" id="argString" value="">

<!-- Button -->
<div class="form-group">
  <label class="col-md-4 control-label" for="Submit"></label>
  <div class="col-md-4">
    <button id="Submit" name="Submit" class="btn btn-primary">Submit</button>
  </div>
</div>

</fieldset>
</form>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="js/bootstrap.min.js"></script>
<script>

$('#NewUserForm').submit(function()
{
        $("#argString").val('-Username ' + $('#Username').val() + ' -EmailAddress ' + $('#EmailAddress').val() + ' -FirstName ' + $('#FirstName').val() + ' -LastName ' + $('#LastName').val() + ' -Department ' + $('#Department').val() + ' -ManagerFN ' + $('#ManagerFN').val() + ' -ManagerLN ' + $('#ManagerLN').val());
});

</script>
<?php else : ?>
    <?php
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL,"http://orl-tasker.presidiolab.local:4440/api/1/job/e6aa66b9-301f-4124-9525-306efb741deb/run");
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS,$_POST);

        // receive server response ...
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $server_output = curl_exec ($ch);

        curl_close ($ch);
    ?>
    <!-- Begin page content -->
    <div class="container">
      <div class="page-header">
        <h1>Thank You For Registering</h1>
      </div>
      <p class="lead">You should receive an email shortly.  If you do not receive an email within one hour, please email DLSouthlabadmins at presidio dot com.</p>
    </div>
<?php endif; ?>
</body>
</html>