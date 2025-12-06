# Running an NGINX Web Server in a Docker Container

In todayâ€™s DevOps and cloud-native world, the ability to quickly spin up services in isolated environments is invaluable. **Docker** enables this with lightweight, portable containers.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/b109228bad8e31729b29e85bab2de633bcde3e4f/Docker%20Labs/Lab%2001/images/Arch.svg)

This lab will guide you through the **end-to-end process of running an NGINX web server inside a Docker container**, using a step-by-step approach. By following these steps, you will learn how to pull the NGINX Docker image, configure a simple HTML file to be served by NGINX, and run the web server inside a container.

## Lab Overview

In this lab, you will:

- Understand what Docker and NGINX are.
- Pull the official NGINX Docker image.
- Create and serve a custom HTML page from a Docker container.
- Map ports and volumes to connect host and container environments.
- Learn how to manage the lifecycle of the container (start, stop, logs, delete).

## Concepts Explained

Before jumping into the lab, letâ€™s understand the key technologies used:

### What is Docker?

Docker is a containerization platform that packages your applications and their dependencies into a **container**. These containers are lightweight, portable, and consistent across environments.

### What is NGINX?

NGINX is a high-performance web server known for its speed and low resource usage. It can also act as a reverse proxy, load balancer, and HTTP cache.

### Docker Image vs. Container

- **Image**: A read-only template used to create containers (e.g., `nginx` image).
- **Container**: A runnable instance of an image with its own isolated filesystem and processes.

## Hands-on: Running NGINX in Docker

### Step 1: Pull the NGINX Docker Image

Letâ€™s start by downloading the official NGINX image from Docker Hub:

```bash
docker pull nginx
```

Youâ€™ll see Docker downloading the image layers. Once complete, youâ€™ll have the latest NGINX image ready to use. 

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image.png)

Check if the image has been downloaded successfully:

```bash
docker images
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-1.png)

### Step 2: Create a Directory for Web Content

We'll store our custom HTML content in a local directory that will later be mapped into the container:

```bash
mkdir -p ~/code/nginx-lab/html
```

This folder will be used to simulate the NGINX serverâ€™s web root. It lets you modify content without accessing the container.

### Step 3: Create a Simple Web Page

Letâ€™s add an HTML file to be served:

```bash
echo '<h1>Hello from NGINX running in Docker!</h1>' > ~/code/nginx-lab/html/index.html
```

This page will be served when you access the NGINX container. This pattern of keeping configuration and content outside the container while the application runs inside is a fundamental Docker best practice.

### Step 4: Run the NGINX Container

Now weâ€™re ready to run the container:

```bash
docker run --name my-nginx \
  -v ~/code/nginx-lab/html:/usr/share/nginx/html:ro \
  -p 8000:80 \
  -d nginx
```

**Letâ€™s break it down:**

- `--name my-nginx`: Names your container "my-nginx".
- `-v ~/code/nginx-lab/html:/usr/share/nginx/html:ro`: Mounts your HTML directory into the container's web root, in read-only mode.
- `-p 8000:80`: Maps port `8000` on your machine to port `80` inside the container (where NGINX listens).
- `-d nginx`: Runs the container in detached mode.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-2.png)

### Step 5: Verify the Setup

#### Check Running Containers:

```bash
docker ps
```

You should see `my-nginx` listed.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-3.png)

#### View the Web Page:

```bash
curl http://localhost:8000
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-4.png)

You can also view the page in your browser:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-5.png)

## Managing the NGINX Container

### Stop the Container

```bash
docker stop my-nginx
```

### Start the Container Again

```bash
docker start my-nginx
```

### View Logs

```bash
docker logs my-nginx
```

This is especially helpful for debugging or monitoring requests.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2001/images/image-6.png)

### Remove the Container

Stop and then remove the container:

```bash
docker stop my-nginx
docker rm my-nginx
```

## Conclusion

Congratulations! Youâ€™ve just completed a practical, hands-on lab to run an NGINX web server inside a Docker container. Along the way, you explored foundational concepts like containerization, image management, port mapping, and volume mounting. You also learned how to serve a custom HTML page and manage the NGINX container with ease.

This lab highlights how Docker makes it incredibly simple to deploy web services in a portable, reproducible way. Whether you're building a static site, creating a reverse proxy, or deploying a microservice architecture â€” this knowledge forms the foundation of modern DevOps workflows.

# Understanding the Lifecycle of a Container

Docker containers are lightweight, standalone, and executable units that contain everything needed to run a piece of software. But what happens to a container after it's created? How do we manage its lifecycleâ€”from creation to deletionâ€”and ensure data inside it persists across restarts?

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/b109228bad8e31729b29e85bab2de633bcde3e4f/Docker%20Labs/Lab%2002/images/Container.svg)

In this hands-on lab, weâ€™ll walk through the **complete lifecycle of a Docker container** using a practical example with a container named `percy`.

## Lab Overview

In this lab, you will:

- Understand the stages of a container's lifecycle.
- Learn essential Docker commands for managing containers.
- Explore what happens to data inside a container.
- Interactively practice starting, stopping, restarting, and deleting a container.

## Concepts Covered

Before jumping into the hands-on part, letâ€™s understand some key concepts:

- **Container**: A running instance of an image that packages an application with its dependencies.
- **Image**: A static specification that includes everything needed to run an app.
- **Lifecycle Stages**: Containers move through stages such as `created`, `running`, `stopped`, and `removed`.
- **Data Persistence**: Data written to the containerâ€™s filesystem persists between restarts, but is lost if the container is removed (unless volumes are used).

## Step-by-Step Lab Instructions

### 1ï¸. Create and Start a Container

In this lab, we will use the `ubuntu:latest` image. It's a lightweight Linux distribution image that provides a minimal Ubuntu environment, commonly used for general-purpose testing, scripting, or running lightweight services.

```bash
docker run --name percy -it ubuntu:latest /bin/bash
```

This command creates and starts a container named `percy` using the `Ubuntu` image. Letâ€™s break down what each part of this command does:

- `docker run`: This tells Docker to create and start a new container.
- `--name percy`: This gives the container a custom name â€” in this case, "percy" â€” so you can easily reference it later.
- `-it`: This is a combination of two options:
  - `-i` stands for interactive, which keeps the standard input (STDIN) open so you can interact with the container.
  - `-t` allocates a pseudo-terminal, allowing you to use the container in a terminal-like environment.
- `ubuntu:latest`: This specifies the Docker image to use. We're using the official Ubuntu image, and `latest` means weâ€™re pulling the most recent version available.
- `/bin/bash`: This is the command that gets executed when the container starts. It launches a Bash shell, giving you an interactive Linux session inside the container.

Once this command runs, you'll find yourself inside the container with a shell prompt like: 

```bash
root@<container_id>:/#
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2002/images/image.png)

At this point, youâ€™re operating inside the container and can run Linux commands just like you would on any regular Ubuntu system.

### 2ï¸. Write Data Inside the Container

```bash
cd /tmp
echo "This is the file about container lifecycle" > newfile
ls -l
cat newfile
```

Youâ€™ve now created a file inside the containerâ€™s filesystem. This simulates real-world data generation.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2002/images/image-1.png)

### 3ï¸. Exit and Stop the Container

1. Type `exit` to exit the container.
2. Then run:

    ```bash
    docker stop percy
    ```

    This stops the container but doesnâ€™t delete it.

### 4ï¸. List Containers

Check running containers:

```bash
docker ps
```

There should be no container listed as there is no container running.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2002/images/image-2.png)

Check all containers, including stopped ones:

```bash
docker ps -a
```

You should see the `percy` container listed as `Exited`.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2002/images/image-3.png)

### 5ï¸. Restart the Container

```bash
docker start percy
```

Then verify:

```bash
docker ps
```

Your container should now show `Up` status.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2002/images/image-4.png)

### 6ï¸. Verify Data Persistence

Now, let's verify that the data persists even after stopping and restarting the container.

```bash
docker exec -it percy bash
cd /tmp
ls -l
cat newfile
```

**Output:**

```
This is the file about container lifecycle
```

This confirms the data persisted even after stopping and restarting the container.

### 7ï¸. Delete the Container

Now, let's delete the container. First, type `exit` to exit the container.

```bash
docker stop percy
docker rm percy
docker ps -a
```

The `percy` container is now gone.

## Summary

| Action          | Command                            |
|----------------|-------------------------------------|
| Create & start  | `docker run --name percy -it ubuntu:latest /bin/bash` |
| Write file      | `echo "..." > newfile`             |
| Stop container  | `docker stop percy`                |
| Restart         | `docker start percy`               |
| Re-enter        | `docker exec -it percy bash`       |
| Delete          | `docker rm percy`                  |

## Conclusion

In this lab, you gained hands-on experience with managing a Docker container's lifecycle from creation to deletion. You saw how data written to a container is preserved across restarts, and you practiced common commands that are essential for working with Docker in real-world environments.

Understanding these lifecycle stages is crucial for:

- Debugging containerized apps
- Building CI/CD pipelines
- Managing stateful services in dev or prod environments

This foundational knowledge sets you up for more advanced Docker topics like volumes, networking, orchestration with Kubernetes, and beyond.

# Differentiating Docker `stop` vs `kill`

Welcome to this hands-on lab on **Docker container termination** techniques. In containerized environments, it's vital to understand how containers are terminatedâ€”gracefully or forcefullyâ€”as it directly impacts application reliability and data integrity.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/b109228bad8e31729b29e85bab2de633bcde3e4f/Docker%20Labs/Lab%2003/images/Docker-Stop-Kill.svg)

This lab will guide you through the **concepts and practical usage of `docker stop` and `docker kill`**, helping you visually grasp the differences using interactive container scenarios.

## Lab Overview

By the end of this lab, you will:

- Understand what signals Docker uses to stop and kill containers.  
- Observe how containers handle `SIGTERM` and `SIGKILL` signals.  
- Use Docker commands to run containers, send termination signals, and inspect logs.  
- Distinguish between graceful and forceful container shutdowns with real examples.

## Conceptual Background

Before diving into the practical steps, letâ€™s first understand the key concepts:

### Docker Signals: What Happens Under the Hood?

When you terminate a Docker container, Docker sends **Unix signals** to the process running inside the container.

#### `docker stop`

- **Signal Sent**: `SIGTERM` (Signal Terminate)
- **Grace Period**: Waits **10 seconds** (by default) for the process to terminate gracefully.
- **Fallback**: Sends `SIGKILL` if the process doesnâ€™t stop in time.

#### `docker kill`

- **Signal Sent**: `SIGKILL` (Signal Kill)
- **Effect**: Immediately stops the process with **no chance** for clean-up.

### Why Does It Matter?

- If your app needs to **release resources**, **write logs**, or **close connections**, use `docker stop`.
- Use `docker kill` only when the container is **unresponsive or hung**.

## Using `docker stop` (Graceful Termination)

### Step 1: Start a Container That Handles `SIGTERM`

Letâ€™s run a container that **traps the SIGTERM signal** and exits cleanly.

```bash
docker run --name graceful-termination -d ubuntu:latest \
  /bin/bash -c "trap 'echo SIGTERM received; exit 0' SIGTERM; while :; do echo 'Running'; sleep 1; done"
```

#### What This Command Does

| Part | Description |
|------|-------------|
| `docker run` | Starts a new container |
| `--name graceful-termination` | Names the container for easy reference |
| `-d` | Runs it in the background (detached mode) |
| `ubuntu:latest` | Uses the latest Ubuntu image |
| `/bin/bash -c "..."` | Runs a custom script inside the container |

**Inside the Script:**
- `trap 'echo SIGTERM received; exit 0' SIGTERM`: If the process receives a `SIGTERM`, it will echo a message and exit cleanly.
- `while :; do echo 'Running'; sleep 1; done`: An infinite loop that prints â€œRunningâ€ every second, to simulate a long-running process.

This setup helps us test how gracefully a container can shut down when it receives a termination signal.

### Step 2: Observe the Container in Action

You can confirm it's running using:

```bash
docker ps
```

You should see `graceful-termination` listed.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2003/images/image.png)

### Step 3: Stop the Container

Now gracefully stop the container:

```bash
docker stop graceful-termination
```

Docker will:
- Send `SIGTERM`
- Wait up to 10 seconds
- Send `SIGKILL` only if the process does not exit

### Step 4: View the Logs

Letâ€™s check how the container responded:

```bash
docker logs graceful-termination
```

**Expected Output:**

```plaintext
Running
Running
Running
SIGTERM received
```

You can see that the container **received the SIGTERM** and exited cleanly.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2003/images/image-1.png)

## Using `docker kill` (Forceful Termination)

### Step 1: Run a Similar Container with Ubuntu Image

```bash
docker run --name force-termination -d ubuntu:latest \
  /bin/bash -c "trap 'echo SIGTERM received; exit 0' SIGTERM; while :; do echo 'Running'; sleep 1; done"
```

### Step 2: Kill the Container Immediately

```bash
docker kill force-termination
```

This skips the graceful exit and sends `SIGKILL` directly.

### Step 3: View the Logs

```bash
docker logs force-termination
```

**Expected Output:**

```plaintext
Running
Running
Running
```

You wonâ€™t see `SIGTERM received` because the container was killed before it could handle any signal.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/refs/heads/main/Docker%20Labs/Lab%2003/images/image-2.png)

## Conclusion

This lab demonstrates the difference between Docker's stop and kill commands using interactive container experiments. These commands might seem similar at first glance since they both terminate a running containerâ€”but their internal behaviors and impact on applications are very different. Understanding how and when to use each is key to ensuring smooth container operations. Use `docker stop` for regular shutdowns and `docker kill` only as a last resort when containers become unresponsive.




| Restart Policy         | Container exits/crashes on its own | Manual `docker stop <name>` → then `docker ps` | After that, you run `sudo systemctl restart docker` → then `docker ps` | After daemon restart, container final status |
|------------------------|-------------------------------------|------------------------------------------------|--------------------------------------------------------------------------|-----------------------------------------------|
| **always**             | Restarts automatically             | Container **stops** → not visible in `docker ps` (only in `docker ps -a`) | Docker daemon comes back → container **starts again automatically**     | **Running**                                   |
| **unless-stopped**     | Restarts automatically             | Container **stops** → not visible in `docker ps` | Docker daemon comes back → container **stays stopped** (respects your manual stop) | **Exited** (stopped)                          |
| **on-failure**         | Restarts only if exit code ≠ 0     | Container **stops** → not visible in `docker ps` | Docker daemon comes back → container **stays stopped**                  | **Exited** (stopped)                          |
| **no policy** (default)| Never restarts                     | Container **stops** → not visible in `docker ps` | Docker daemon comes back → container **stays stopped**                  | **Exited** (stopped)                          |

### Quick live example you can copy-paste right now

```bash
# 1. Create the three test containers
docker run -d --name always         --restart always         alpine sleep 1d
docker run -d --name unless        --restart unless-stopped alpine sleep 1d
docker run -d --name onfailure     --restart on-failure     alpine sleep 1d

# 2. They are all running
docker ps

# 3. Manually stop all three
docker stop always unless onfailure

# 4. They disappear from docker ps (all Exited)
docker ps          # → nothing
docker ps -a       # → all three Exited

# 5. Restart the Docker daemon
sudo systemctl restart docker   # or sudo service docker restart

# 6. Check what came back to life
docker ps          # → ONLY the "always" container is running
docker ps -a       # → "unless" and "onfailure" are still Exited
```

Result you will see:

```
CONTAINER ID   IMAGE   COMMAND        STATUS              NAMES
abc123def456   alpine  "sleep 1d"     Up 10 seconds       always
```

## To control number of restart for failure  

- `on-failure:10` → Valid and very common  

- `unless-stopped:10` → Invalid, Docker refuses to start the container  

- `always:10` → Also invalid

If you want a real service that survives crashes **but** also want to avoid infinite crash loops, the usual workaround is:

```bash

# Option 1: Just use unless-stopped (most people do this)

--restart unless-stopped

# Option 2: If you are really afraid of crash loops, combine healthcheck + on-failure

--restart on-failure:5 \

--health-cmd "your-health-check-command" \

--health-interval 10s

# REAL WORLD EXAMPLE

# This container will fail immediately, 10 times max. The -c part for exiting manually and viewing the crashing...
docker run -d --name crash-test \
  --restart on-failure:10 \
  alpine sh -c "echo crashing...; exit 42"

# Watch the restarts with backoff. watch tool runs this commands -n 1 means each second.If we write 0.5 it means each 0.5 second.
watch -n 1 "docker ps -a --filter name=crash-test; echo; docker inspect crash-test --format '{{.State.RestartCount}} restarts'"

```
# Understanding Docker Bind Mounts

Docker has transformed the way we develop, deploy, and manage applications by leveraging containerization. One of its standout features, **bind mounts**, provides a flexible mechanism for connecting a containerâ€™s filesystem with the host system. In this lab, weâ€™ll dive deep into what bind mounts are, how they work in the context of Linuxâ€™s single-tree storage structure, and walk through a practical example using an NGINX web server. Letâ€™s explore this powerful feature step-by-step.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-1.png)

## The Foundation: Linux Storage and Mount Points

Before we delve into bind mounts, itâ€™s worth understanding how storage operates in a Linux environment. Unlike some operating systems that treat storage devices as separate entities, Linux organizes all storage into a **single tree structure**. This hierarchical filesystem begins at the root directory (`/`) and integrates various storage devicesâ€”such as disk partitions, USB drives, or network sharesâ€”by attaching them to specific locations within the tree. These attachment points are known as **mount points**.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-2.png)

A mount point serves as a gateway, defining where a storage device connects to the filesystem, its access properties (e.g., read-only or read-write), and the source of the mounted data. This abstraction allows users and applications to interact with files seamlessly, without needing to understand the underlying storage mappings. In the context of Docker containers, this concept becomes even more powerful. Each container operates with its own isolated filesystem, complete with a unique root and set of mount points, enabling efficient and isolated environments.

## What Are Bind Mounts?

At their core, **bind mounts** are a Docker feature that lets you map specific files or directories from the host system into a containerâ€™s filesystem. Think of it as creating a direct bridge between the host and the container, allowing them to share data in real time. Unlike Docker volumes, which are managed by Docker and stored in a designated location (typically `/var/lib/docker`), bind mounts rely on paths explicitly defined on the host.

Hereâ€™s a breakdown of what makes bind mounts special:

- **Direct Mapping**: When you create a bind mount, you specify a source (a file or directory on the host) and a target (a location inside the container). The container then â€œseesâ€ the hostâ€™s data at that target location as if it were part of its own filesystem.
- **Real-Time Synchronization**: Any changes made to the mounted files or directoriesâ€”whether from the host or the containerâ€”are instantly reflected in both environments. This bidirectional link is what enables seamless interaction between the two.

Bind mounts are particularly useful when you need a containerized application to access or modify data on the host system, such as configuration files, logs, or source code.

## How Do Bind Mounts Work?

The mechanics of bind mounts are straightforward yet powerful. When you set up a bind mount, Docker essentially â€œremountsâ€ a portion of the hostâ€™s filesystem into the container. Hereâ€™s how it happens:

1. **Source and Target Specification**: You define a source path on the host (e.g., `~/myfile.txt`) and a target path in the container (e.g., `/app/myfile.txt`).
2. **Mounting Process**: Docker uses the Linux `mount` system call with the `--bind` option to attach the source to the target. This creates a direct link, effectively overlaying the hostâ€™s data onto the containerâ€™s filesystem at the specified location.
3. **Immediate Updates**: Because the bind mount establishes a live connection, any modificationsâ€”whether adding, editing, or deleting filesâ€”are mirrored instantly across both the host and the container.

This real-time interaction makes bind mounts ideal for scenarios where data persistence or direct access to host resources is critical.

## Practical Example: Running NGINX with Bind Mounts

To illustrate bind mounts in action, letâ€™s consider a scenario where weâ€™re running an NGINX web server inside a Docker container. Our goal is to:
- Provide NGINX with a custom configuration file stored on the host.
- Allow NGINX to write access logs to a file on the host.


![](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/mapping.drawio.svg)

Using bind mounts, we can achieve this seamlessly. Hereâ€™s how to set it up, step by step.

### Step 1: Preparing the Host Files

First, we need to create the files that NGINX will use inside the container.

1. **Create an Empty Log File**  
   On the host, weâ€™ll create an empty file to store NGINXâ€™s access logs:
   ```bash
   touch ~/example.log
   ```
   This command generates `example.log` in the userâ€™s home directory (`~`). NGINX will later write its access logs to this file via a bind mount.

2. **Create a Custom NGINX Configuration File**  
   Next, weâ€™ll define a simple NGINX configuration:
   ```bash
   cat > ~/example.conf <<EOF
   server {
     listen 80;
     server_name localhost;
     access_log /var/log/nginx/custom.host.access.log main;
     location / {
       root /usr/share/nginx/html;
       index index.html index.htm;
     }
   }
   EOF
   ```
   This creates `example.conf` in the home directory with the following settings:
   - The server listens on port 80.
   - It serves files from `/usr/share/nginx/html` (NGINXâ€™s default content directory).
   - Access logs are written to `/var/log/nginx/custom.host.access.log`.

These files will serve as the source paths for our bind mounts.

### Step 2: Launching the NGINX Container with Bind Mounts

Now, letâ€™s run the NGINX container and use bind mounts to connect the host files to the container.

1. **Define Variables for Clarity**  
   To keep our command clean, weâ€™ll set variables for the source and target paths:
   ```bash
   CONF_SRC=~/example.conf
   CONF_DST=/etc/nginx/conf.d/default.conf
   LOG_SRC=~/example.log
   LOG_DST=/var/log/nginx/custom.host.access.log
   ```
   - `CONF_SRC` and `LOG_SRC` are the paths to our files on the host.
   - `CONF_DST` and `LOG_DST` are the paths where these files will appear inside the container.

2. **Run the Container**  
   Execute the following Docker command:
   ```bash
   docker run -d --name diaweb \
     --mount type=bind,src=${CONF_SRC},dst=${CONF_DST} \
     --mount type=bind,src=${LOG_SRC},dst=${LOG_DST} \
     -p 8000:80 \
     nginx:latest
   ```
   Letâ€™s break this down:
   - `-d`: Runs the container in detached mode (in the background).
   - `--name diaweb`: Names the container `diaweb`.
   - `--mount type=bind,src=${CONF_SRC},dst=${CONF_DST}`: Binds `example.conf` from the host to `/etc/nginx/conf.d/default.conf` in the container, overriding NGINXâ€™s default configuration.
   - `--mount type=bind,src=${LOG_SRC},dst=${LOG_DST}`: Binds `example.log` to `/var/log/nginx/custom.host.access.log`, allowing NGINX to write logs to it.
   - `-p 8000:80`: Maps port 8000 on the host to port 80 in the container, making the web server accessible at `http://localhost:8000`.
   - `nginx:latest`: Uses the latest NGINX image from Docker Hub.

Once executed, the container starts, and NGINX begins serving content based on our custom configuration.



### Step 3: Verifying the Setup

Letâ€™s confirm that everything is working as expected.

1. **Access the Web Server**  
   Test the NGINX server by sending a request:
   ```bash
   curl http://localhost:8000
   ```

   You should see NGINXâ€™s default welcome page HTML, indicating the server is running correctly.

   You can also check the Nginx UI at the following URL:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-4.png)

   Click on the URL to see the Nginx UI.

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-3.png)

2. **Check the Logs**  
   Inspect the log file on the host:
   ```bash
   cat ~/example.log
   ````

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-5.png)

   Youâ€™ll see an entry corresponding to the `curl` request, confirming that NGINX is writing logs to the host file via the bind mount.


### Step 4: Securing the Configuration with Read-Only Mounts

For added security, we can configure the bind mount for the configuration file to be read-only, preventing the container from modifying it.

1. **Stop and Remove the Existing Container**
  
   Clean up the previous container:
   ```bash
   docker stop diaweb
   docker rm -f diaweb
   ```

2. **Relaunch with a Read-Only Mount**  
   Run the container again, adding the `readonly=true` option:
   ```bash
   docker run -d --name diaweb \
     --mount type=bind,src=${CONF_SRC},dst=${CONF_DST},readonly=true \
     --mount type=bind,src=${LOG_SRC},dst=${LOG_DST} \
     -p 8000:80 \
     nginx:latest
   ```
   The `readonly=true` flag ensures that `/etc/nginx/conf.d/default.conf` inside the container cannot be altered.

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-6.png)


### Step 5: Testing the Read-Only Restriction

Letâ€™s verify that the read-only setting works by attempting to modify the configuration file inside the container:
```bash
docker exec diaweb \
  sed -i "s/listen 80/listen 81/" /etc/nginx/conf.d/default.conf
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-7.png)

This command tries to change the listening port from 80 to 81. However, because the bind mount is read-only, it will fail with a permission error, confirming that the restriction is enforced.


## Key Considerations When Using Bind Mounts

While bind mounts are incredibly useful, they come with some trade-offs:

- **Portability**: Bind mounts depend on specific paths on the host filesystem. If those paths donâ€™t exist or differ on another host, the container wonâ€™t function as expected, making it less portable compared to Docker volumes.
- **Potential Conflicts**: If multiple containers bind mount the same host directory for writable data, they might overwrite each otherâ€™s changes, leading to data corruption or unexpected behavior.

Careful planning can mitigate these issues, such as using unique paths or opting for Docker   volumes when portability is a priority.



## Conclusion

Docker bind mounts offer a robust solution for integrating a containerâ€™s filesystem with the host, enabling real-time data sharing and persistence. Whether youâ€™re managing configuration files, logs, or application data, bind mounts provide the flexibility to bridge the gap between isolated containers and the host environment.


# In-Memory Storage

Many service software and web applications require handling sensitive configuration files such as **private key files, database passwords, and API key files**. These files should never be included in the image or written to disk for **security** reasons. Instead, utilizing `in-memory storage` is crucial to ensure sensitive data remains secure. This readme provides guidance on implementing in-memory storage using Docker containers with tmpfs mounts.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/newDiagram1.svg)

## Using tmpfs Mounts
To implement in-memory storage, we can use `tmpfs` mounts with Docker containers. The `tmpfs` mount type allow us to create *a memory-based filesystem* within the container's `file tree`.

## Command Syntax
We can use the following command to mount a `tmpfs` device into a container's file tree:

```bash
docker run --rm \
    --mount type=tmpfs,dst=/tmp \
    --entrypoint mount \
    alpine:latest -v
```
![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/image.png)

## Command Explanation
- `--mount type=tmpfs,dst=/tmp`: This part of the command specifies that a `tmpfs` device will be mounted at the `/tmp` directory within the container's file system.
- `--entrypoint mount`: This specifies the `entry point` for the container as the `mount` command.
- `alpine:latest`: This indicates the Docker image to be used for the container.

## Configuration Details

When the above command is executed, it creates an **empty tmpfs device** and attaches it to the container's file tree at `/tmp`. Files created under this file tree will be stored in **memory instead of on disk**. The mount point is configured with sensible defaults for generic workloads. 

## Mount-point Configuration
Upon execution, the command displays a list of all mount points for the container. Here's a breakdown of the configuration provided:

- `tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noexec,relatime)`: This line describes the mount-point configuration.
  - `tmpfs on /tmp`: Indicates that a tmpfs device is mounted to the tree at `/tmp`.
  - `type tmpfs`: Specifies that the device has a `tmpfs` filesystem.
  - `rw`: Indicates that the tree is `read/write` capable.
  - `nosuid`: Specifies that `suid` bits will be ignored on all files in this tree.
  - `nodev`: Indicates that no files in this tree will be interpreted as `special` devices.
  - `noexec`: Specifies that no files in this tree will be `executable`.
  - `relatime`: Indicates that file `access times` will be updated if they are older than the current modify or change time.

## Additional Options
We can further customize the tmpfs mount by adding the following options:

- `tmpfs-size`: Specifies the `size limit` of the tmpfs device.
- `tmpfs-mode`: Specifies the `file mode` for the tmpfs device.

## Example Command with Additional Options

```bash
docker run --rm \
    --mount type=tmpfs,dst=/app/tmp,tmpfs-size=16k,tmpfs-mode=1770 \
    --entrypoint mount \
    alpine:latest -v
```

This command limits the tmpfs device mounted at `/tmp` to **16 KB** and configures it to be *not readable* by other in-container users.

## Example Scenerio

Consider a scenario where you're developing a **microservice-based application** that requires handling *sensitive* configuration files and *temporary data* processing. Instead of storing these files on disk, you opt for `in-memory` storage to enhance security and performance.

## Implementation:

### **Step 01. Docker Configuration**:

- Create a Dockerfile for the microservice.
- Configure the Dockerfile to use a tmpfs mount for storing sensitive data in memory.

    ```Dockerfile
    # Use an official Python runtime as a base image
    FROM python:3.9-slim

    # Set the working directory in the container
    WORKDIR /app

    # Copy the current directory contents into the container at /app
    COPY . .

    # Ensure the directory exists
    RUN mkdir -p /app/tmp

    # Run the application and keep the container running
    CMD ["sh", "-c", "python3 example_microservice.py && tail -f /dev/null"]
    ```

### **Step 02. Sensitive Data Processing**:

- Now task is to develop a microservice to generate and process sensitive data within the memory-based filesystem.
- We have to ensure that any temporary files or sensitive configuration files are created and accessed within the mounted tmpfs directory.


#### Create a simple micorservice named `example_microservice.py`


```python
import os

# Path to temporary directory within the mounted tmpfs
tmp_dir = "/app/tmp"

def process_sensitive_data(data):
    # Ensure the temporary directory exists.
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    # Write sensitive data to a temporary file within the mounted tmpfs
    with open(os.path.join(tmp_dir, "sensitive_data.txt"), "w") as f:
        f.write(data)
    
    # Perform processing on the sensitive data
    with open(os.path.join(tmp_dir, "sensitive_data.txt"), "r") as f:
        processed_data = f.read()
        print(f"Processed Data: {processed_data}")

# Example usage
data_to_process = "This is sensitive data"
process_sensitive_data(data_to_process)
```

In this completion:
- We have created a simple microservice named `example_microservice.py` that processes sensitive data within
the mounted tmpfs directory.
- The microservice ensures the temporary directory exists and writes sensitive data to a file within the mounted `tmpfs` directory.
- The microservice then reads the sensitive data from the file and performs some processing on it.
- The processed data is then printed to the console.
- The microservice uses the `os` module to interact with the file system and ensure that all file operations are performed within the mounted `tmpfs` directory.

### **Step 03: Build and Run Docker Container**:

- Build the Docker image for the microservice.
- Run the Docker container, ensuring that the tmpfs mount is properly configured.

    ```bash
    # Build Docker image
    docker build -t my_microservice .
    ```
    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/image-2.png)

    ```sh
    docker run --rm -d \
        --mount type=tmpfs,dst=/app/tmp,tmpfs-size=16k,tmpfs-mode=1770 \
        my_microservice
    ```
    ```bash
    docker ps
    ```
    
    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/image-4.png)

### **Step 04: Ensure that the tmpfs mount is properly configured**

To ensure that the `tmpfs` mount is properly configured when running the Docker container involves verifying that the **container has access to the tmpfs-mounted directory** and that **sensitive data is being stored within this directory**. Here's how we can ensure this:

1. **Verify Mount Configuration**: When running the Docker container, ensure that the tmpfs mount is configured correctly. we can do this by inspecting the container's mounts:

    ```bash
    docker inspect <container_id_or_name>
    ```

    ![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/4.png)

    This command will display information about the container, including its mounts. Ensure that the tmpfs mount is listed and mounted at the expected directory (e.g., `/app/tmp`).

2. **Check File Storage Location**: Confirm that sensitive data is being stored within the tmpfs-mounted directory. We can do this by examining the files created or accessed by the container.

    ```bash
    docker exec -it <container_id_or_name> /bin/bash
    ````
    ```sh
    cd tmp && ls
    cat sensitive_data.txt 
    ```
    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2013/images/image-3.png)

So we have successfully completed the task!

## How do Docker Volumes work?

A Docker Volume is a directory that is **shared** between the host machine and a container. When you create a volume, Docker creates a directory on the host machine, and mounts it to a directory inside the container. This allows data to be written to the volume, which is persisted even when the container is deleted or recreated.

## Example Scenerio: Using Docker volumes with a NoSQL Database (Apache Cassandra)

In this scenario, we will use `Docker` to create and manage a single-node `Cassandra cluster`. We'll create a `keyspace`, delete the container, and then recover the `keyspace` on a new node in another container using Docker volumes. Follow the detailed steps below:

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/newDiagram2.svg)

## Step 1: Create Docker Volume

First, we will create a Docker volume that will store the `Cassandra database` files. This volume will use `disk space` on the local machine.

```bash
docker volume create \
    --driver local \
    --label example=cassandra \
    cass-shared
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/1.png)

**Explanation:** 

- **docker volume create:** Command to create a Docker volume.
- **--driver local:** Specifies that the volume should use the local driver.
- **--label example=cassandra:** Adds a label to the volume for easier management and identification.
- **cass-shared:** The name of the volume.





## Step 2: Run a Cassandra Container

First, create a **user-defined bridge network** so containers can communicate by name.
(The default `bridge` network does **not** support DNS name resolution.)

```bash
docker network create cass-net
```

Now run a Cassandra container inside that network and mount the volume:

```bash
docker run -d \
    --network cass-net \
    --volume cass-shared:/var/lib/cassandra/data \
    --name cass1 \
    cassandra:2.2
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/2.png)

**Explanation:**

* **docker network create cass-net**: Creates a user-defined network that supports DNS service discovery (container names resolve automatically).
* **docker run -d**: Runs the container in detached mode.
* **--network cass-net**: Attaches the container to the `cass-net` network (required for name-based communication).
* **--volume cass-shared:/var/lib/cassandra/data**: Mounts the shared volume.
* **--name cass1**: Names the container `cass1`. This becomes its hostname inside the network.
* **cassandra:2.2**: Uses Cassandra 2.2 from Docker Hub.

---

## Step 3: Connect to the Cassandra Container

To connect to the running Cassandra server, run a temporary container using the **same network** and execute the `cqlsh` client tool.

```bash
docker run -it --rm \
    --network cass-net \
    cassandra:2.2 \
    cqlsh cass1
```

**Explanation:**

* **--network cass-net**: Needed so this container can resolve `cass1` by name.
* **cassandra:2.2**: Runs a temporary Cassandra container which includes the `cqlsh` tool.
* **cqlsh cass1**:

  * `cqlsh` = Cassandra Query Language shell (client program)
  * `cass1` = hostname of the Cassandra server container

This drops you into the Cassandra shell, connected to the `cass1` node.





> “If I already have Cassandra/Postgres/MySQL running in a container,
> why do I need to run a *second* container with `cqlsh` / `psql` / `mysql`?
> Can't I just run SQL inside the server container itself?”

Great question — and the answer is:

# ✅ **You *can* run the client inside the server container…

…but you *usually don’t*, and there are good reasons why.**

Let’s break this down clearly.

---

# ⭐ **1. Some server containers DO include the client tool, but not all**

### Cassandra container includes:

* `cqlsh` → YES

### PostgreSQL container includes:

* `psql` → YES

### MySQL container includes:

* `mysql` client → YES

### Redis container includes:

* `redis-cli` → YES

So yes — technically, you *can* exec into the server container and use the client tool:

Example:

```bash
docker exec -it cass1 cqlsh
```

This works.

---

# 🛑 **So why do people run a separate client container?**

Because of these reasons:

---

# 1️⃣ **Best practice: Don’t mix server and client environments**

Your database server container should:

* run *only* the DB server
* not be used as a client workstation

Running tools inside it mixes responsibilities.

---

# 2️⃣ **You may want to connect from outside the server container**

Example:

* from a Python app container
* from an admin tool container
* from CI/CD scripts
* from automation scripts

So learning:

```
docker run <client-image> <client-tool> <host>
```

is the **universal** pattern.

---

# 3️⃣ **Some images remove client tools to stay small**

Modern images often use slimmer builds.

Example:

* MySQL “debian-slim” → *no client tools*
* Postgres alpine → *no client tools*
* Cassandra “slim” → *no Python*, so `cqlsh` doesn’t work

In those cases:

* **exec into server container = doesn’t work**
* but *client containers always work*

---

# 4️⃣ **Client needs to run on the same network as apps**

In real environments:

* apps run in different containers → not inside the DB server container
* clients need to reach the database from *their own* environment

Running a client container teaches the correct networking pattern:

```bash
--network mynet
```

---

# 5️⃣ **You may want multiple versions of the client**

Example:

* Connect to Postgres 13 using a Postgres 16 client
* Use Cassandra 4.0 `cqlsh` to connect to Cassandra 2.2

Using the server container ties you to the server’s version.

---

# 6️⃣ **Exec’ing into running containers is not portable**

On Kubernetes, ECS, Swarm:

* You cannot exec into containers easily
* You *must* use a separate client container

So learning this pattern is necessary.

---

# 🔥 **So what’s the short explanation?**

### ✔️ They *could* support SQL inside the container

(because the client tools are installed)

### ❌ But it’s not best practice to use the DB server container as a client environment

because:

* It’s bad separation of roles
* Not all images include clients
* Apps must connect from separate containers
* Client versions might differ
* Server containers should stay clean and minimal

---

# 🧠 Real-life analogy

Running `cqlsh` inside the Cassandra server container is like:

> Editing your thesis on the same machine that hosts your production web servers.

You *can*, but it’s not good practice.

Better to use a separate machine (or in Docker’s case, a separate container).

---

# ✔️ Final Answer

> They **do** support SQL tools inside the server container,
> BUT you should NOT rely on those tools.
>
> It’s better to run the client in a separate container because:
>
> * cleaner separation of roles
> * works with slim images
> * works in real deployments (Kubernetes, Compose)
> * supports version mismatch
> * supports multi-container networks

---

 

**Explanation:**

- **docker run -it --rm:** Runs the container interactively and removes it after exit.
- **--link cass1:cass:** Links the client container to the cass1 container.
- **cassandra:2.2:** Uses the Cassandra image version 2.2.
- **cqlsh cass:** Runs the CQLSH command line tool to connect to the Cassandra server.

Now you can inspect or modify your `Cassandra database` from the `CQLSH` command line. First, look for a keyspace named `docker_hello_world`:

```sql
select *
from system.schema_keyspaces
where keyspace_name = 'docker_hello_world';
```

**Explanation:**

- select * from system.schema_keyspaces where keyspace_name = 'docker_hello_world';: Queries the system schema for the docker_hello_world keyspace.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/3.png)

Cassandra should return an *empty* list. This means the database hasnâ€™t been *modified* by the example.

## Step 04: Create and Verify a Keyspace

Inside the CQLSH shell, create a keyspace named `docker_hello_world`.

```sql
create keyspace docker_hello_world
with replication = {
    'class' : 'SimpleStrategy',
    'replication_factor': 1
};
```

**Explanation:**

- create keyspace: Creates a new keyspace.
- docker_hello_world: The name of the keyspace.
- with replication = { 'class' : 'SimpleStrategy', 'replication_factor': 1 }: Specifies the replication strategy and factor.

### Verify the keyspace creation:

```sql
select *
from system.schema_keyspaces
where keyspace_name = 'docker_hello_world';
```

If the keyspace was created successfully, you will see the entry in the query result.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/4.png)

## Step 5: Stop and Remove the Cassandra Container

Exit the CQLSH shell and remove the Cassandra container.

```bash
quit
```

```bash
docker stop cass1
docker rm -vf cass1
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/5.png)

**Explanation:**

- **quit**: Exits the CQLSH shell.
- **docker stop cass1**: Stops the cass1 container.
- **docker rm -vf cass1**: Removes the cass1 container `forcefully` and deletes associated `resources`.

## Step 6: Test Data Recovery

Create a new Cassandra container and attach the volume to it.

```bash
docker run -d \
    --volume cass-shared:/var/lib/cassandra/data \
    --name cass2 \
    cassandra:2.2
```

```bash
docker ps
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/6.1.png)

### Connect to the new Cassandra container using CQLSH.

```bash
docker run -it --rm \
    --link cass2:cass \
    cassandra:2.2 \
    cqlsh cass
```

### Query the keyspace to verify data persistence.

```sql
select *
from system.schema_keyspaces
where keyspace_name = 'docker_hello_world';
```

If the keyspace docker_hello_world is listed in the result, it confirms that the data `persisted` in the `cass-shared` volume.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/7.png)

## Step 7: Clean Up

Exit the `CQLSH shell` and remove the containers and volume.

```bash
quit
```

```bash
docker rm -vf cass2
docker volume rm cass-shared
```

**Explanation:**

- **quit**: Exits the CQLSH shell.
- **docker rm -vf cass2**: Removes the cass2 container forcefully.
- **docker volume rm cass-shared**: Deletes the cass-shared volume.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/8.png)


# Log Sharing Between Containers

In this Lab, we will demonstrate the process of sharing files between multiple Docker containers using two methods: `bind mounts` and `Docker volumes`. The goal is to showcase the benefits of Docker volumes over bind mounts, and to illustrate the flexibility and ease of use provided by anonymous volumes and the `--volumes-from` flag.

## Scenario Overview

### Bind Mount Example
We start by setting up a directory on the host and bind-mounting it into two containersâ€”one for writing log files and one for reading them.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/new1.svg)

### Docker Volume Example

 We then perform the same operation using Docker volumes, eliminating host-specific dependencies.

### Anonymous Volumes and `--volumes-from` Flag

Finally, we demonstrate using anonymous volumes and the `--volumes-from` flag to dynamically share volumes between multiple containers.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/new2.svg)

## Initial setup:

First we will create a docker image that performs simple file writting application in a Docker container. Hereâ€™s how you can create your own:

**1. Create a Dockerfile**

```Dockerfile
FROM alpine:latest
RUN apk add --no-cache bash
CMD ["sh", "-c", "while true; do date >> /data/logA; sleep 1; done"]
```

**2. Build the Docker image**

```sh
docker build -t my_writer .
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-7.png)

**3. Verify the docker image**

```sh
docker images
```
![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-8.png)

## Log sharing using Bind Mount:

**1. Setup a Known Location on Host**:

```sh
LOG_SRC=~/web-logs-example
mkdir ${LOG_SRC}
```
- **LOG_SRC**: This is an environment variable that stores the path to the directory where the logs will be stored.
- **mkdir ${LOG_SRC}**: This command creates a new directory at the path specified by LOG_SRC.

**2. Create and Run a Log-Writing Container and use `bind mounts` to share the log directory**:

```sh
docker run --name plath -d \
    --mount type=bind,src=${LOG_SRC},dst=/data \
    my_writer
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-9.png)

**3. Create and Run a Log-Reading Container and use `bind mounts` to share**:

```sh
docker run --rm \
    --mount type=bind,src=${LOG_SRC},dst=/data \
    alpine:latest \
    head /data/logA
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-10.png)

*Explanation:*

- **docker run**: This command creates and starts a new container.
- **--name plath**: This names the container "plath".
- **-d**: This flag runs the container in detached mode, meaning it runs in the background.
- **--mount type=bind,src=${LOG_SRC},dst=/data**: This option specifies a bind mount. It maps the host directory (src) to the container directory (dst).
  - **type=bind**: Indicates the type of mount.
  - **src=${LOG_SRC}**: Source directory on the host.
  - **dst=/data**: Destination directory inside the container.
- **--rm**: This flag automatically removes the container when it exits.
- **alpine:latest**: The image used to create the container. Alpine is a lightweight Linux distribution.
- **head /data/logA**: This command reads the top part of the log file.

**View Logs from Host**:

We can also view the logs directly from the host.

```sh
cat ${LOG_SRC}/logA
```
- **cat**: This command displays the contents of the file.
- **${LOG_SRC}/logA**: Path to the log file on the host.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-11.png)

**Stop the Log-Writing Container**:

```sh
docker rm -f plath
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-2.png)

## Log sharing using Docker Volume: 

Now we will achieve the same result using docker volume.

**1. Create Docker Volume**:

```sh
docker volume create --driver local logging-example
docker volume ls
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image.png)

**Explanation:**

- **docker volume create**: This command creates a new Docker volume.
- **--driver local**: This specifies the volume driver to use. "local" is the default driver.
- **logging-example**: Name of the volume.

**2. Create and Run a Log-Writing Container**:

```sh
docker run --name plath -d \
    --mount type=volume,src=logging-example,dst=/data \
    my_writer
```

**3. Create and Run a Log-Reading Container**:

```sh
docker run --rm \
    --mount type=volume,src=logging-example,dst=/data \
    alpine:latest \
    head /data/logA
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-12.png)

**Explanation:**

- **docker run**: This command runs a new container.
- **--mount type=volume,src=logging-example,dst=/data**: This option specifies a volume mount.
  - **type=volume**: Indicates the type of mount.
  - **src=logging-example**: Source volume.
  - **dst=/data**: Destination directory inside the container.


**4. View Logs from Host**:

```sh
cat /var/lib/docker/volumes/logging-example/_data/logA
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-4.png)


**5. Stop the Log-Writing Container**:
```sh
docker stop plath
```

## Anonymous Volumes

Now, let's explore using anonymous volumes and the `--volumes-from` flag.

**1. Create Containers with Anonymous Volumes**:
```sh
docker run --name fowler \
    --mount type=volume,dst=/library/PoEAA \
    --mount type=bind,src=/tmp,dst=/library/DSL \
    alpine:latest \
    echo "Fowler collection created."

docker run --name knuth \
    --mount type=volume,dst=/library/TAoCP.vol1 \
    --mount type=volume,dst=/library/TAoCP.vol2 \
    --mount type=volume,dst=/library/TAoCP.vol3 \
    --mount type=volume,dst=/library/TAoCP.vol4.a \
    alpine:latest \
    echo "Knuth collection created"
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-1.png)

**Explanation:**

- **--mount type=volume,dst=/library/PoEAA**: Creates an anonymous volume mounted at /library/PoEAA.
- **--mount type=bind,src=/tmp,dst=/library/DSL**: Creates a bind mount from /tmp on the host to /library/DSL in the container.

**2. Share Volumes with Another Container**

Create a container that uses the volumes from the previous containers.

```sh
docker run --name reader \
    --volumes-from fowler \
    --volumes-from knuth \
    alpine:latest ls -l /library/
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-5.png)

**Explanation:**

- **--volumes-from fowler**: Copies the mount points from the container "fowler".
- **--volumes-from knuth**: Copies the mount points from the container "knuth".
- **ls -l /library/**: Lists the contents of the /library/ directory.

**3. Inspect Volumes of the New Container**:

Check the volumes of the new container.

```sh
docker inspect --format "{{json .Mounts}}" reader | jq .
```

*Expected Output:* (Make sure to install `jq` command-line tool if you want to format the JSON output in a prettier way)

```bash
sudo apt-get update
sudo apt install jq -y
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-13.png)
- **docker inspect**: Provides detailed information about Docker objects.
- **--format "{{json .Mounts}}"**: Formats the output to show the mounts of the container.

## Cleaning up volumes

### Removing a Specific Volume

```sh
docker volume ls
docker volume rm <volume_name>
```

### Pruning Unused Volumes

```sh
docker volume prune
```

### Forcefully Removing All Volumes

```sh
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume rm $(docker volume ls -q)
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2015/images/image-14.png)

By following these procedures, you can efficiently manage and remove Docker volumes, ensuring your Docker environment remains clean and optimized.

### Conclusion

This scenario highlights the advantages of using Docker volumes over bind mounts for sharing files between containers. Docker volumes offer better portability, simplified management, and improved security. Additionally, using anonymous volumes and the `--volumes-from` flag provides dynamic and flexible data sharing, making it easier to manage complex containerized applications.


# Communication Between Containers in a Custom Bridge Network

When working with Docker, containers by default are isolated. However, when containers need to communicate with each other, you can connect them to the same Docker network. A **user-defined bridge network** provides more control over how Docker containers communicate compared to the default bridge network. This guide will walk you through setting up a custom bridge network, launching multiple Nginx containers on that network, and verifying communication between them.

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/new.svg)

## Why Use a User-Defined Bridge Network?

By default, Docker containers can communicate over a built-in network called the "default bridge network." However, using a **user-defined bridge network** provides the following benefits:

- **Name resolution:** Containers connected to the same network can communicate by their container names, making it easier to manage multi-container setups.
- **Isolated environment:** Containers on a user-defined network are isolated from others unless explicitly connected to other networks.
- **Security:** You can control which containers can communicate by connecting them only to specific networks.
  
Now, let's move on to creating the network and launching our containers.


## Creating the User-Defined Bridge Network

The first step is to create a custom bridge network. Docker allows you to create networks of different types, such as `bridge`, `overlay`, and `host`. Here, we'll use the **bridge** driver, which is the default type for local container communication on a single host.

Run the following command to create the network:

```shell
docker network create --driver bridge my-bridge-network
```

This command creates a bridge network named `my-bridge-network`. You can inspect the network details using the command below:

```shell
docker network inspect my-bridge-network
```

This will give you detailed information about the network, including its subnet, gateway, and connected containers.

### Verifying Network Creation

You can list all existing Docker networks by running:

```shell
docker network ls
```

Expected Output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-1.png)

The newly created `my-bridge-network` should appear in the list, showing that it uses the `bridge` driver.

## Launching Containers and Connecting to the Network

In this section, we'll launch three containers (`container1`, `container2`, and `container3`), each running the **Nginx** web server, and connect them to our user-defined network.

### Launching Container 1

We use the following command to launch `container1`, and immediately connect it to the `my-bridge-network` network:

```shell
docker run -d --name container1 --network=my-bridge-network nginx
```

This will run the Nginx web server in the background (`-d`) and assign the name `container1` to the instance.

### Launching Container 2

Similarly, to launch `container2`, use:

```shell
docker run -d --name container2 --network=my-bridge-network nginx
```

### Launching Container 3

Finally, to launch `container3`, use:

```shell
docker run -d --name container3 --network=my-bridge-network nginx
```

With all three containers running, they are now connected to the same network, `my-bridge-network`. This enables them to communicate directly with one another.


## Verifying Container Status

To check the status of the running containers, use the command:

```shell
docker ps
```

Expected output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-2.png)

Here, you'll see the list of running containers along with their names, statuses, and other details like port mappings. The containers `container1`, `container2`, and `container3` should be listed as running, confirming that Nginx is operational inside each container.


## Verifying Communication Between Containers

Now that the containers are up and running, let's check if they can communicate with each other using their container names.

### Accessing the Shell of Container 1

First, we'll access the shell of `container1` to ping the other containers. Run:

```shell
docker exec -it container1 /bin/bash
```

This opens an interactive shell session inside `container1`. From this session, we can try pinging the other containers by their names.

### Pinging Container 2 from Container 1


To test connectivity from `container1` to `container2`, we will run a ping command. First we need to install the `ping` command in the `container1`.

```shell
apt-get update
apt-get install -y iputils-ping
```

Now we can ping `container2` from `container1`.

```shell
ping container2 -c 5
```

This command will send 5 ICMP echo requests to `container2`. A successful ping will indicate that `container1` can communicate with `container2`.

Expected Output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-3.png)

### Pinging Container 3 from Container 1

Next, try pinging `container3` from `container1`:

```shell
ping container3 -c 5
```

Expected Output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-4.png)

The successful responses confirm that `container1` can reach both `container2` and `container3` within the custom network.

### Accessing the Shell of Container 2

We can repeat the process from another container. Access the shell of `container2` by running:

```shell
docker exec -it container2 /bin/bash
```

Once inside the shell, you can ping `container1` and `container3`.

### Pinging Container 1 from Container 2

First we need to install the `ping` command in the `container2`.

```shell
apt-get update
apt-get install -y iputils-ping
```

Now we can ping `container1` from `container2`.

```shell
ping container1 -c 5
```

Expected Output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-6.png)

### Pinging Container 3 from Container 2

```shell
ping container3 -c 5
```

Expected Output:

![image](https://raw.githubusercontent.com/poridhiEng/lab-asset/77a2d45b5fcf1f17580591d7edd73aa97b1eaf51/Docker%20Labs/Lab%2016/images/out-5.png)

These tests confirm that all the containers can communicate with each other over the custom bridge network.

## Conclusion

By following these steps, we successfully created a user-defined bridge network and launched multiple Nginx containers connected to the network. We verified that they can communicate with each other by pinging container names. This demonstrates how Docker networking facilitates smooth communication between containerized applications, making it easier to manage interconnected services.


# Understanding Bridge Networks in Docker: A Comprehensive Guide

In the world of containerization, Docker stands out as a powerful tool for deploying and managing applications. One of its key features is the ability to manage networking between containers, and bridge networks play a central role in facilitating this communication. In this lab, weâ€™ll dive deep into Dockerâ€™s bridge networks, exploring how to create custom networks, attach containers to multiple networks, and use diagnostic tools like `ip` and `nmap` to inspect network configurations and discover other containers. Whether youâ€™re a beginner or an experienced Docker user, this guide will provide you with a clear and detailed understanding of bridge networks.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image-1.png)

## What Are Bridge Networks?

Before we jump into the technical details, letâ€™s clarify what a bridge network is in Docker. By default, Docker uses a bridge network to enable communication between containers on the same host. A bridge network is essentially a virtual network that acts as a middleman, connecting containers to each other and, optionally, to the outside world via the host machine. Itâ€™s built on top of Linuxâ€™s bridge functionality, providing a layer of isolation while allowing controlled connectivity.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image.png)

When you launch a container without specifying a network, Docker attaches it to the default bridge network (`bridge`). However, for more control over IP addressing, subnet configuration, and container communication, you can create custom bridge networks. These custom networks are the focus of this lab, as they offer greater flexibility and functionality.

## Creating and Inspecting a Custom Bridge Network

Letâ€™s begin by creating a custom bridge network and breaking down the process step by step. Open your terminal and execute the following command:

```bash
docker network create \
  --driver bridge \
  --label project=dockerinaction \
  --label br-net \
  --attachable \
  --scope local \
  --subnet 10.0.42.0/24 \
  --ip-range 10.0.42.128/25 \
  user-network
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image-2.png)

This command creates a custom bridge network named `user-network`. Letâ€™s dissect its components to understand whatâ€™s happening:

- **`--driver bridge`**: Specifies that weâ€™re using the bridge driver, which is the default networking mode for container communication on a single host.
- **`--label project=dockerinaction --label br-net`**: Adds metadata labels to the network. Labels are useful for organization and filtering, especially in large projects.
- **`--attachable`**: Makes the network attachable, meaning standalone containers (not just those managed by Docker Compose) can connect to it dynamically.
- **`--scope local`**: Limits the networkâ€™s scope to the local Docker host, ensuring it doesnâ€™t span multiple hosts (unlike overlay networks).
- **`--subnet 10.0.42.0/24`**: Defines the subnet for the network, in this case, a range of 256 IP addresses (from `10.0.42.0` to `10.0.42.255`).
- **`--ip-range 10.0.42.128/25`**: Restricts the assignable IP addresses to a subset of the subnet, specifically `10.0.42.128` to `10.0.42.255` (128 addresses).
- **`user-network`**: The name of the network, which weâ€™ll use to reference it later.

This configuration gives us a tailored network environment with precise control over IP allocation and container connectivity.

### Inspecting the Network

Once the network is created, you can inspect its details using the `docker network inspect user-network` command. The output will include information about the subnet, IP range, gateway, and any containers currently attached. This step is crucial for verifying that the network matches your intended configuration.

Now, letâ€™s launch a container and connect it to this network:

```bash
docker run -it \
  --network user-network \
  --name network-explorer \
  alpine:3.8 \
    sh
```

Hereâ€™s what this command does:
- **`docker run -it`**: Starts an interactive terminal session in the container.
- **`--network user-network`**: Attaches the container to our custom `user-network`.
- **`--name network-explorer`**: Names the container for easy reference.
- **`alpine:3.8 sh`**: Uses the lightweight Alpine Linux image (version 3.8) and starts a shell (`sh`).

Once inside the container, run the following command to examine its network interfaces:

```bash
ip -f inet -4 -o addr
```

This command lists the IPv4 addresses assigned to the containerâ€™s interfaces. Youâ€™ll see output resembling:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image-3.png)

- **`lo`**: The loopback interface (`127.0.0.1`), present in all networked systems.
- **`eth0`**: The containerâ€™s Ethernet interface, assigned an IP like `10.0.42.129` from the `user-network`â€™s IP range.

This confirms that the container is successfully connected to `user-network` and has an IP within the specified range.

## Attaching Containers to Multiple Networks

One of Dockerâ€™s powerful features is the ability to connect a single container to multiple networks. Letâ€™s create a second bridge network, `user-network2`, and attach our `network-explorer` container to it.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/multi-net.drawio.svg)

First, create the new network:

```bash
docker network create \
  --driver bridge \
  --label project=dockerinaction \
  --label br-net \
  --attachable \
  --scope local \
  --subnet 10.0.43.0/24 \
  --ip-range 10.0.43.128/25 \
  user-network2
```

This command mirrors the earlier one but uses a different subnet (`10.0.43.0/24`) and IP range (`10.0.43.128/25`). To see all available networks, run:

```bash
docker network ls
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image-4.png)

Youâ€™ll see both `user-network` and `user-network2` listed, along with the default networks like `bridge`, `host`, and `none`.

Now, connect the `network-explorer` container to `user-network2`:

```bash
docker network connect \
  user-network2 \
  network-explorer
```

This dynamically attaches the running container to the second network. Inside the container, re-run the `ip -f inet -4 -o addr` command. Youâ€™ll now see an additional interface (e.g., `eth1`) with an IP from `user-network2`, such as `10.0.43.129`. This demonstrates how a container can participate in multiple isolated networks simultaneously, enhancing its communication capabilities.

## Enhancing Exploration with `nmap`

To dive deeper into network discovery, letâ€™s install and use `nmap` (Network Mapper) inside the `network-explorer` container. First, install it:

```bash
docker exec -it network-explorer sh -c "apk update && apk add nmap"
```

- **`docker exec -it`**: Executes a command inside the running `network-explorer` container.
- **`apk update && apk add nmap`**: Updates the Alpine package index and installs `nmap`.

Why use `nmap`? Itâ€™s a versatile tool for network exploration, allowing us to scan for active devices, troubleshoot connectivity, and audit security within the containerized environment.

### Scanning the Networks

With `nmap` installed, scan the subnets of both networks:

```bash
nmap -sn 10.0.42.* 10.0.43.* -oG /dev/stdout | grep Status
```

Breaking this down:
- **`-sn`**: Performs a ping scan (no port scanning), checking for live hosts.
- **`10.0.42.* 10.0.43.*`**: Targets the subnets of `user-network` and `user-network2`.
- **`-oG /dev/stdout`**: Outputs results in a greppable format to the terminal.
- **`grep Status`**: Filters the output to show only the status of discovered hosts.

The output might look like:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2017/images/image-5.png)

This reveals:
- The containerâ€™s IPs (`10.0.42.129` and `10.0.43.129`), confirming its presence on both networks.

This scan provides a snapshot of active devices, helping you map out the network topology.

## Conclusion

Dockerâ€™s bridge networks offer a robust framework for managing container communication. By creating custom networks, attaching containers to multiple networks, and leveraging tools like `ip` and `nmap`, you gain granular control and visibility into your containerized environment. These skills are invaluable for designing scalable network architectures, troubleshooting connectivity issues, and ensuring efficient application deployment.