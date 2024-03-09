---
title: 'Overall Goals'
weight: 5
---

# Overall Project Goals

The overall project goals encompass a range of objectives that go beyond the functional requirements of the system.
These goals primarily focus on the non-functional aspects, aiming to ensure the system's performance, reliability,
security, and usability. By considering these non-functional requirements, the project aims to deliver a robust and
user-friendly solution that meets the standards of quality and user satisfaction.

## Ease Of Use:

One of the key non-functional requirements of the project is the ease of use. The system should be intuitive and
user-friendly, catering to users of varying technical expertise. By focusing on usability, the project aims to minimize
the learning curve and enable users to configure and interact with the system effortlessly. This includes providing
clear and concise instructions, intuitive log messages, and logical workflows. The system should be designed with a
user-centric approach, considering factors such as readability, accessibility, and consistency in design. By
prioritizing ease of use, the project seeks to enhance user satisfaction, encourage adoption, and facilitate efficient
utilization of the system's functionalities.

### Rules to ensure

- To configure a feature it must be clearly named and their name must say what the setting does
- Less configuration is preferred over complex alternatives
- Log messages should say a) what happens and b) why it happens and c) what the user can do to fix it

## Security

Another crucial non-functional requirement is security. The system should be designed with robust security measures to
protect sensitive data and prevent unauthorized access. This includes implementing software with security-first mindset.
One reason why we choose Swift as a language is that Swift has been designed with a strong emphasis on memory safety.
It implements automatic memory management through ARC (Automatic Reference Counting), reducing the risk of common
memory-related vulnerabilities such as buffer overflows, dangling pointers, and memory leaks. Do not work around it!
Prefer immutable types and immutable variables. The project aims to ensure the confidentiality, integrity, and
availability of the system and its data, safeguarding against potential security breaches and vulnerabilities. By
prioritizing security, the project seeks to establish trust and confidence among users, promoting the adoption and
continued usage of the system.

### Rules to ensure

- Use Swift's standard library that provides security-focused components, such as cryptographic APIs, which are
  essential for secure development. It includes support for common cryptographic operations like hashing, encryption,
  and secure random number generation. The availability of these built-in security features reduces the need for
  external libraries.
- Use modern Syntax and Features: Swift incorporates modern programming language features that contribute to safer
  coding practices. It includes features like strong type inference, pattern matching, and safer error handling with
  the "try-catch" mechanism. These features encourage developers to write more robust and secure code by minimizing
  common sources of bugs and vulnerabilities. Adapt language improvements early.
- Do not bleed any user relevant information to console or logs.

## Performance

Furthermore, performance is a vital non-functional requirement for the project. The system should be designed and
optimized to deliver exceptional speed and responsiveness, ensuring that users can log in efficiently
without experiencing any significant delays or performance bottlenecks. Even so, the developer and administrator of an
Uitsmijter instance should to the work without performance bottlenecks. This includes efficient data processing, quick
response times for user interactions, and minimal system downtime. By prioritizing performance, the project aims to
create a seamless user experience that maximizes productivity and minimizes frustration. A high-performing system will
not only enhance user satisfaction but also increase the overall efficiency and effectiveness of the tasks performed
within the system.

### Rules to ensure

- Choose appropriate algorithms and data structures that are efficient for the specific problem
- Minimize I/O Operations: Minimize disk I/O, network requests, and file operations whenever possible.
- Utilize asynchronous programming techniques to handle time-consuming tasks in a non-blocking manner.
- Conduct regular performance testing and profiling to identify performance bottlenecks.
