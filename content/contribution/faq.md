---
title: 'Frequently Asked Questions'
weight: 6
---

# Why there is no Admin-Interface for Uitsmijter?

Adding an admin UI to the server software can have its drawbacks and may not be the best approach for the following
reasons:

1. There should be one way to do it (see [Project Goals](/contribution/goals): Introducing an admin UI means providing
   one other way to configure and manage the server software that is hard to sync back to descriptive files in
   Kubernetes. This can limit flexibility and customization options for users who prefer different tools for editing
   configuration files. By sticking solely to YAML configuration files, users
   can leverage their preferred text editors, version control systems, and automation tools, allowing for greater
   flexibility and compatibility with existing workflows.
2. YAML configuration files provide a well-established and widely adopted method for configuring
   server software. They are human-readable, versionable, and easy to share, making them a popular choice for many
   server administrators. Adding an admin UI alongside configuration files may introduce confusion and complexity by
   having multiple ways to configure the software, potentially leading to configuration inconsistencies and conflicts.
3. Developing and maintaining an admin UI requires additional effort and resources. It involves designing and
   implementing a user-friendly interface, handling user input validation, managing UI-specific issues, and keeping the
   UI in sync with any changes or updates to the underlying server software. This added complexity can increase
   development and maintenance overhead. This is subtracted from the time spent working on an understandable and easy to
   use descriptive setting.
4. Server administrators are typically comfortable working with the command line and text-based interfaces. They are
   accustomed to configuring and managing server software through the console and may prefer the flexibility and
   efficiency it offers. Introducing an admin UI may not align with the preferences and expectations of the target
   audience, potentially resulting in a less intuitive or less efficient user experience.
5. Web-based admin interfaces introduce additional security risks, such as potential vulnerabilities in the UI
   framework, the need for proper authentication and authorization mechanisms, and the potential for cross-site
   scripting (XSS) or other web-related attacks. By avoiding an admin UI, you can minimize the attack surface and reduce
   the potential for security breaches associated with web-based interfaces.
6. An admin UI is the entry to hiding complexity behind shiny buttons and checkboxes. We do not want to hide complexity,
   we want to avid it at the first place.

This explains why Uitsmijter does not and will never have an administrative interface.
