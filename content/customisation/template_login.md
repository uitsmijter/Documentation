---
title: 'Login Page'
weight: 1
---

# Login- and Logout-Page Customisation

There are multiple ways to customize the login and logout pages.  
The easiest way is to configure additioanl [tenant informations](/configuration/tenant_client_config#properties)
like imprint, privacy policy and registration URLs.

In addition to that it is also possible to change page templates because every `tenant` can have their own login page.

## Loading templates from template directory
In the source code version of Uitsmijter you can to create a folder that is named after the slug of the tenant name.

Open the folder `Resources` / `Views` and create a new folder. Assuming the tenant is called `example`, from the
project root create a folder for the templates:

```shell
mkdir Resources/Views/example
```

and copy the default templates in that folder:

````shell
cp -r Resources/Views/default/* Resources/Views/example
````

Now you can edit the file `Resources/Views/example/login.leaf` to build your own customized login page. The correct
template will be selected automatically by the tenant requesting the login.

> Uitsmijter uses [Leaf](https://docs.vapor.codes/leaf/overview/) templates to render pages.

## Loading templates from S3 bucket
When Uitsmijter is deployed via kubernetes it is easier to load the templates from an external source.
For that case Uitsmijter supports loading tempalte files from a S3 compatible storage provider.

You can configure the S3 access  as `templates` int your `tenant.yaml`,
as described in the [Tenant](/configuration/tenant_client_config#properties) configuration.
The template files will be loaded to Uitsmijter when the tenant is read.
You can view the expected directory structure and file names in `Resources/Views/default`, not all files must be provided.

## Settings

### On Error

If an error occurred, then the `error` variable is set with the `error_token`.

> Hint:
> You may want to set extra classes on error. You can use the helper `isnotempty(:var, :print)` to print out some text
> when `:var` is empty.
> eg:
> ```html
>    <div class='login-box #isnotempty(error, "error")'>
> ```
> _If `error? is not empty, say: "error"

To render the error you have to translate it into the user requested language:

```html
#if(error != nil):
<div class="error">#t(error)</div>
#endif
```

### Translation

To translate a token use `#t(:token)`.

You may want to provide your own sentences for the errors. You can do a big if-else chain for each of the error
messages:

```html
#if(error == "LOGIN.ERRORS.FORM_NOT_PARSEABLE"):
<div>...</div>
#elseif(error == "LOGIN.ERRORS.CONSTRUCT_DATE_ERROR"):
<div>...</div>
#elseif(error == "LOGIN.ERRORS.MISSING_LOCATION"):
<div>...</div>
#elseif(error == "LOGIN.ERRORS.NO_TENANT"):
<div>...</div>
#elseif(error == "LOGIN.ERRORS.WRONG_CREDENTIALS"):
<div>...</div>
```

### Login Form

The form action have to point to `#(serviceUrl)/login`
and the following form fields must be provided:

| field    | value         |
|----------|---------------|
| location | #(requestUri) |
| username |               |
| password |               |
