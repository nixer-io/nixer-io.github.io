---
layout: page
homepage: true
short_title: Getting Started
side_menu: true
permalink: /getting-started/
---

# Getting Started

### Plugin in Spring Boot MVC application

In this getting started tutorial we will go though the process of integrating Nixer plugin into the simple Spring MVC application. If however you want to see necessary changes right away look at [the diff in examples repository](https://github.com/nixer-io/nixer-spring-plugin-integrations/compare/with%2Fnixer-plugin-getting-started?diff=split). Branch `master` contains application only and branch `with/nixer-plugin-getting-started` contains all the necessary modification to the codebase to have the plugin working.

### Spring application
First, let’s check out the default application we will use in this tutorial. Let’s clone the GitHub repository, build the application and run it locally.
```
$ git clone https://github.com/nixer-io/nixer-spring-plugin-integrations.git
$ cd nixer-spring-plugin-integrations/nixer-spring-plugin-demo-app
$ ./gradlew bootRun 
```

By default, the application will start on port 8080 and this is the port I will use in this demo.

After application startup, go to: [http://localhost:8080](http://localhost:8080) and login with credentials:
```
username: demo
password: demo
```
As you can see, this is a very simple _Todo app_. The application uses the most simple and standard way of doing things in Spring Boot. In the next step, we will explore the behavior of such a default application under credential stuffing attack.

### Credential stuffing attack
For this example, we will only consider the simplest credential stuffing attack. The attack will consist of consecutive login attempts executed one after another. For simulating this scenario, we will use Postman or rather its headless version Newman.

More specifically, we will use a Nixer fork of Newman with custom modification that provides programmatic access to Cookies - we needed it to automate the test scenarios. You can review our modifications [here on branch feature/cookies-domain-whitelist](https://github.com/nixer-io/newman/compare/develop...feature/cookies-domain-whitelist). 

In order to test the application, go to test scenarios directory:
```
$ cd nixer-spring-plugin-integrations/nixer-spring-plugin-demo-app/e2e-tests
```

Install dependencies:
```
$ npm install
```

Now you we can run a test scenario. There are number of test scenarios, let’s try basic credential stuffing, 
which repeats one hundred login attempts. Each attempt consists of two HTTP requests, GET for obtaining the login page 
and POST that sends the credentials. We will be executing a command that produces significant output size, so let's copy the output to a file _results.txt_ with `tee`. In order to execute the scenario run the following command:
```
$ node test-cs.js | tee results.txt
```

Executed requests and summary of the responses will be printed to the output in a form of a table. 
It is not intuitive to read, but by looking at `iterations` row you can see that all login attempts were executed. By looking at the `assertions` row you can see that all requests were executed and expected responses from the server were returned.

{:.table}
|                      | executed  | failed |
|----------------------|-----------|--------|
| `iterations`         | 99        | 0      |
| `requests`           | 198       | 0      |
| `test-scripts`       | 396       | 0      |
| `prerequest-scripts` | 396       | 0      |
| `assertions`         | 495       | 0      |
| `total run duration: 16.2s`  


Summary table shows that all login requests were executed without issues. You can look in the `test-cs.data.csv` file for credentials 
that were used for login attempts. It means that credentials attacks are possible, it took 16 seconds for the test to to enumerate 100 credentials and perform necessary checks. Of course, we're doing the test locally so in real-world scenarios we would have network delays as well.

Now that we established that default Spring Boot web application is prone to credential attacks, let’s explore how applying Nixer plugin can change it. 

### Integrate captcha
In this section we are going to start modifying code of the demo application under `nixer-spring-plugin-integrations/nixer-spring-plugin-demo-app`. 

The plugin modules are available in [Maven Central](https://mvnrepository.com/artifact/io.nixer). 

We are going to start this tutorial by using two of them, the mandatory [Core module]({{ site.baseurl }}/core) and the
[Captcha module]({{ site.baseurl }}/core) providing captcha protection.

Let’s add them as dependencies to the `build.gradle` file:
```
implementation "io.nixer:nixer-plugin-core:0.1.1.0"
implementation "io.nixer:nixer-plugin-captcha:0.1.1.0"
```

Now, we can start adding features to the application. The plugin leverages Spring Boot's [auto configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/using-spring-boot.html#using-boot-auto-configuration) mechanism, so needed beans will be created automatically.

At the beginning let’s add Google Captcha v2 mechanism to our login page. 
If you plan to add this to your own application register captcha for your application [at Google](https://www.google.com/recaptcha/admin/create). 
However, for the sake of this tutorial, you can use our example captcha configuration.

For captcha to work, we need 3 configuration strings: 
* site key - used to invoke reCAPTCHA on our site,
* secret key - authorizes communication between our application backend and the reCAPTCHA server to 
[verify the user’s response](https://developers.google.com/recaptcha/docs/verify),
* verify url - refers to Google API address and is consumed by Nixer to automatically verify captcha responses. 

Let’s add needed captcha configuration to the `application.properties` file:

```properties
nixer.captcha.recaptcha.verifyUrl=https://www.google.com/recaptcha/api/siteverify
nixer.captcha.recaptcha.key.site=6LetVa4UAAAAAPpwWsl3LRRk8qCRfZvKJjE0U4Om
nixer.captcha.recaptcha.key.secret=6LetVa4UAAAAAAAa1f1PaqgStH8rgV5sqTlUxGd4
```

We will have to apply the captcha to login page. In this application, login page is defined in the Thymeleaf template file:
`templates/login.html`. Let’s modify it to include Google reCAPTCHA v2 checkbox version. You can read about details in 
[the official reCAPTCHA documentation](https://developers.google.com/recaptcha/docs/display). 

We have to load captcha script by adding following line in the `<head>` section: 
```html
<script src='https://www.google.com/recaptcha/api.js' async defer></script>
```

We also need to modify the login form by adding:
```html
<div class="g-recaptcha" th:attr="data-sitekey=${@captchaKeyProvider.getSiteKey()}"></div>
```

inside the `<form>` component, **after the password input**. As you can see, we’re injecting site key from `io.nixer.nixerplugin.captcha.recaptcha.CaptchaKeyProvider` bean.

Now if you start the application, for example with:
```
$ ./gradlew bootRun
```

a reCAPTCHA box is going to appear on the login page. 
However, the result of the captcha is not yet validated, so you can login correctly without clicking on the captcha.

In order to enable captcha verification, we have to enhance Spring Security authentication mechanism. Common method for defining authentication and authorization strategies is through `org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter` class. In `io.nixer.springplugin.demo.WebSecurityConfig` class, we configure simple `org.springframework.security.config.annotation.web.builders.HttpSecurity` object and we provide in-memory authentication for the sake of this demo. Let’s inject `io.nixer.nixerplugin.captcha.security.CaptchaChecker` bean into the class:
```java
@Autowired
private CaptchaChecker captchaChecker;
```

We also need to modify authentication manager in `io.nixer.springplugin.demo.WebSecurityConfig` class by adding captcha post processor, using `configurer.withObjectPostProcessor` method:
```java
@Override
protected void configure(final AuthenticationManagerBuilder auth) throws Exception {
    PasswordEncoder encoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
    final InMemoryUserDetailsManagerConfigurer<AuthenticationManagerBuilder> configurer = 
                                               auth.inMemoryAuthentication().passwordEncoder(encoder);

    users().forEach((user, pass) -> configurer.withUser(user)
                                              .password(encoder.encode(pass))
                                              .roles("USER"));

    configurer.withObjectPostProcessor(new CaptchaConfigurer(captchaChecker));
}
```

Finally, we have to configure captcha check condition in the `application.properties` file:
```properties
nixer.login.captcha.condition=ALWAYS
```

Condition can be set to `NEVER`, `ALWAYS` and `SESSION_CONTROLLED`. We will return to these values later in the tutorial.

Now, it’s time to run the application again (`$ ./gradlew bootRun`). This time, an attempt to login without passing captcha mechanism will fail with _“Invalid username and password.”_ (for the simplicity of this tutorial we don’t distinguish fail reasons here). 

At this point we have a successfully integrated Google reCAPTCHA v2 within the Spring application. Congrats!

For now, captcha is displayed for each user and for each login attempt which would stop credential stuffing (under assumption that reCAPTCHA v2 can’t be bypassed by bots). 

However, the current credential stuffing protection is very simple and it impacts negatively user experience. 
In the next section we will explore how we can improve our mechanism.

### Nixer plugin - Behaviors
Nixer plugin offers control over what protection mechanism to use in particular situations. To achieve that, we provide behaviors, rules 
and conditions abstractions.
 Altogether they provide high configurability and control over the protection mechanism. Let’s use it to enhance our captcha solution.

Straightforward enhancement for our captcha mechanism would be to display the captcha to a user only after failed login attempts. 
For example, we can ask for captcha after 3 failed login attempts. In Nixer plugin, this is very easy to implement.

First, let’s change captcha checking condition from `ALWAYS` to `SESSION_CONTROLLED` in the `application.properties` file:
```properties
nixer.login.captcha.condition=SESSION_CONTROLLED
```  

This property will configure the `io.nixer.nixerplugin.captcha.security.CaptchaChecker` bean. 
This bean knows when captcha should be checked and displayed based on defined conditions. 
We will use its method `CaptchaChecker.shouldDisplayCaptcha()` to tweak the UI to display captcha only when conditions are met. 
Let’s modify `login.html` by adding an if statement to the previously added tags:
```html
<script th:if="${@captchaChecker.shouldDisplayCaptcha()}" src='https://www.google.com/recaptcha/api.js' async defer></script>

...

<div th:if="${@captchaChecker.shouldDisplayCaptcha()}" class="g-recaptcha"
     th:attr="data-sitekey=${@captchaKeyProvider.getSiteKey()}"></div>
```

Now it’s time to define a rule and behavior for it. In the `application.properties` file, we will provide configuration for a rule:
```properties
nixer.rules.failed-login-threshold.username.enabled=true
nixer.rules.failed-login-threshold.username.threshold=3
nixer.rules.failed-login-threshold.username.window=5m
```

Next, in the `io.nixer.springplugin.demo.WebSecurityConfig` class define a bean `io.nixer.nixerplugin.core.detection.filter.BehaviorProviderConfigurer`:
```java
@Bean
public FilterConfiguration.BehaviorProviderConfigurer behaviorConfigurer() {
    return builder -> builder
            .rule("usernameLoginOverThreshold")
            .when(Conditions::isUsernameLoginOverThreshold)
            .then(CAPTCHA)
            .buildRule();
}
```

That’s it, lets run the application again. 

### Checking the results
The application is running, let’s re-run credential stuffing test as before.

```
$ node test-cs.js | tee results.txt
```

__As you can see by inspecting the output or `results.txt` file, nothing changed. We are still vulnerable!__

---
Why?
 
This is a somewhat common misconception that by providing security measure per user account, we are protected against credential stuffing. That’s not true as we just saw. 

So what happened? As you can see by looking at `test-cs.data.csv` file with credentials used for the test, usernames __do not__ repeat. Each login attempt is performed on a different account, so there’s no lockdowns on one particular account happening. 
What should we do instead?
As you probably guessed, we have to look at all login attempts within the system.

### Looking at all login attempts 
One of the strongest signal of credential stuffing, is an increased ratio of failed login attempts. 
As an attacker tries to login with credential lists most of the attempts are going to fail. 
Such scenario would produce a visible pattern, therefore we introduced a metric to monitor failed and successful login attempts. 
We call it simply `failed-login-ratio`. It is calculated as follows:
```
failed-login-ratio = (100 * number or failed logins) / (number of all logins)
```

To enable `failed-login-ratio` mechanism let's add the following to the `application.properties` file:

```properties
nixer.rules.failed-login-ratio-level.enabled=true
nixer.rules.failed-login-ratio-level.activationLevel=65
nixer.rules.failed-login-ratio-level.deactivationLevel=55
nixer.rules.failed-login-ratio-level.minimumSampleSize=10
nixer.rules.failed-login-ratio-level.window=10m
```

Property `activationLevel` defines value of `failed-login-ratio` on which an activation event will be generated. It will be later used by the _Rule_ to apply defined _Behavior_. In this configuration, the rule will be activated when 65% or more of the logins request will be a failed ones. Property `deactivationLevel` defines value of _failed-login-ratio_ below which deactivation event will be generated disabling protection mechanism. 

As you can see, we recommend using hysteresis to prevent frequent activation/deactivation but you are free to modify the values to suit your application's characteristics and your own balance between security and user experience. 

Property `window` defines time period for which the ratio will be calculated. Longer periods would consume more memory (unless external data store is used) and would cause slower reaction to changes in traffic patterns.

Property `minimumSampleSize` defines the smallest number of login attempts that need to occur within `window` for the activation to happen. 
The reason for this property is that when there is a small number of login attempts, we don't necessarily want to trigger activation. 
`minimumSampleSize` set to 10 with `window` set to 10 minutes would mean that we are allowing at most 60 failed login attempts 
(assuming no successful ones) in an one hour time period. 

Now, we need to define a Rule that would trigger a Behavior on _failed-login-ratio_ activation. 
Let's again to `io.nixer.springplugin.demo.WebSecurityConfig` and add a new rule to the builder:
```java
    @Bean
    public FilterConfiguration.BehaviorProviderConfigurer behaviorConfigurer() {
        return builder -> builder
                    .rule("usernameLoginOverThreshold")
                    .when(Conditions::isUsernameLoginOverThreshold)
                    .then(CAPTCHA)
                .buildRule()
                    .rule("failedLoginRatioActive")
                    .when(Conditions::isFailedLoginRatioActive)
                    .then(CAPTCHA)
                .buildRule();
    }
```
We also added _CAPTCHA_ behavior for this rule. 

__And... that's it, time for testing!__

Let's run the application:
```
$ ./gradlew bootRun
```

Navigate to test scenarios and run them:
```
$ cd e2e-tests
$ node test-cs.js | tee results.txt
```

This time the results are following:

{:.table}
|                      | executed  | failed |
|----------------------|-----------|--------|
| `iterations`         | 99        | 0      |
| `requests`           | 198       | 0      |
| `test-scripts`       | 396       | 0      |
| `prerequest-scripts` | 396       | 0      |
| `assertions`         | 495       | 89     |
| `total run duration: 16.2s`  

By looking at `assertions` row we can see 89 login attempts failed because captcha was displayed. If we analyze logs of the application, we would see multiple repetitions of following:
```
FailedLoginRatioRegistry : FAILED_LOGIN_RATIO event was caught with ratio: 1.0
.BehaviorExecutionFilter : Executing behavior: CAPTCHA
``` 
Because in the data we only have non-existing users, failed-login-ratio is 100%. When limit for `minimumSampleSize` is exceeded (10 attempts), all further attempts are required captcha which is not solved by this test, which causes the assertion failure. 

Now, let's examine how the application would act if there would be successful login attempts in the data as well. Let's open `test-cs.data.csv` file in in `e2e-tests` directory. For this example I will modify head of the file by adding correct `demo:demo` login attempts:
```
demo,demo,true
demo,demo,true
demo,demo,true
nonExistingUser1,gup5A686zjnVhw+v,false
nonExistingUser2,PgwWldkDIP15gZ8u,false
demo,demo,true
demo,demo,true
nonExistingUser3,HaMaUiG0UyCi1Yot,false
nonExistingUser4,wb7ac0Ie/79XS/9Y,false
demo,demo,true
nonExistingUser5,5CLWkPL5bmpGUDBg,false
demo,demo,true
nonExistingUser6,ZyS67ePRz0VdKhyd,false
nonExistingUser7,lTqm4co9CdDsylja,false
```
Third column with values _true_ or _false_ indicates whether the credentials are correct (will result in a successfull login), this information can be used by testing tool in some scenarios.

I am leaving the rest of the file unchanged. Now, let's restart the application or wait `window` time period to clear cached data 
(persistence between restarts requires a regular database) and run the test again:
```
$ node test-cs.js | tee results.txt
```

This time the logs contain:
```
FailedLoginRatioRule   : Calculated failed login ratio: 0.4
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.4
FailedLoginRatioRule   : Calculated failed login ratio: 0.4375
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.4375
FailedLoginRatioRule   : Calculated failed login ratio: 0.47058823529411764
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.47058823529411764
FailedLoginRatioRule   : Calculated failed login ratio: 0.5
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.5
FailedLoginRatioRule   : Calculated failed login ratio: 0.5263157894736842
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.5263157894736842
FailedLoginRatioRule   : Calculated failed login ratio: 0.55
FailedLoginRatioRule   : Calculated failed login ratio: 0.5714285714285714
FailedLoginRatioRule   : Calculated failed login ratio: 0.5909090909090909
FailedLoginRatioRule   : Calculated failed login ratio: 0.6086956521739131
FailedLoginRatioRule   : Calculated failed login ratio: 0.625
FailedLoginRatioRule   : Calculated failed login ratio: 0.64
FailedLoginRatioRule   : Calculated failed login ratio: 0.6538461538461539
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.6538461538461539
BehaviorExecutionFilter      : Executing behavior: CAPTCHA
BehaviorExecutionFilter      : Executing behavior: CAPTCHA
FailedLoginRatioRule   : Calculated failed login ratio: 0.6666666666666666
FailedLoginRatioRegistry     : FAILED_LOGIN_RATIO event was caught with ratio: 0.6666666666666666
BehaviorExecutionFilter      : Executing behavior: CAPTCHA
```
By reading the logs, we can see that the ratio was slowly increasing because there were some successful login attempts at the beginning of the test as well. Then, the ratio was increasing and when it exceeded 0.65, a CAPTCHA behavior was applied. The rest of the file contained failed login attempts so, the ratio was increasing consistently till the end of the test. The table looks as following:

{:.table}
|                      | executed  | failed |
|----------------------|-----------|--------|
| `iterations`         | 108       | 0      |
| ...                  | ...       | ...    |
| `assertions`         | 540       | 82     |
| `total run duration: 59s`  

Which means that out 108 login attempts 82 were blocked. 

Now, let's modify the `test-cs.data.csv` file again by adding 20 `demo:demo` attempts at the beginning of the file (25 first login attemps will be correct). Then restart the application again, re-run the test and see the results for such case:
 
{:.table}
|                      | executed  | failed |
|----------------------|-----------|--------|
| `iterations`         | 128       | 0      |
| ...                  | ...       | ...    |
| `assertions`         | 640       | 45     |
| `total run duration: 59s`  

This time, 45 requests were blocked out of 128. As you can see, a lot depends on state of the system but once the ratio increases to the `activationLevel`, it executes Behavior and should not drop below `deactivationLevel` during traditional credential stuffing attack. 

When tuning the parameters it is good to know about two fundamental things: what is the _failed-login-ratio_ for genuine users and what is the rate of login attempts within the system. Though our defaults are quite generic and can be used as a starting point.

We will end further analysis here as this is a _getting started_ tutorial. Feel free to explore source code and other sections of the docs.
