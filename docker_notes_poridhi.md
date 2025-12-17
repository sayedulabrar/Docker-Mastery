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

# Setting Up a Host-Like Environment Using Docker Containers

Docker has revolutionized the way we develop, deploy, and manage applications by providing lightweight, portable containers. Typically, Docker containers are designed to run a single process, adhering to the **one process per container** philosophy. However, there are scenarios where you might want a container to mimic a traditional host environmentâ€”one capable of running multiple services simultaneously, such as a web server and a database. In this lab, weâ€™ll walk you through the process of creating such an environment using Docker, leveraging `supervisord` as a process manager to orchestrate multiple services within a single container.

By the end of this lab, we'll have a fully functional Docker container running Nginx (a web server), MySQL (a database server), and managed by Supervisord, all within a host-like setup. Let's dive into the details.

## Features of the Environment

Before we begin, hereâ€™s a quick overview of the key components this setup will include:

- **Nginx**: A high-performance web server to handle HTTP requests.
- **MySQL**: A robust relational database server for data storage and management.
- **Supervisord**: A process control system to manage and monitor multiple services within the container.

This combination simulates a traditional server environment, where multiple services coexist and operate seamlessly. To illustrate the final setup, refer to the diagram below:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/supervisord.drawio.svg)

## Step-by-Step Setup Process

Now, let's get started with the setup process.

### Step 1: Crafting the Dockerfile

The foundation of any Docker container is its `Dockerfile`, a blueprint that defines the containerâ€™s structure and behavior. Letâ€™s create one **tailored** for our host-like environment.

Create a file named `Dockerfile` and add the following content:

```Dockerfile
# Use an official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to avoid user prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
RUN apt-get update && apt-get install -y \
    nginx \
    mysql-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Add supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for services (e.g., 80 for Nginx, 3306 for MySQL)
EXPOSE 80 3306

# Start supervisord to run multiple services
CMD ["/usr/bin/supervisord"]
```

#### Breaking It Down

- **Base Image**: We start with `ubuntu:latest`, a lightweight yet familiar Linux distribution that provides the flexibility to install multiple services.
- **Environment Variable**: The `DEBIAN_FRONTEND=noninteractive` setting prevents interactive prompts during package installations, ensuring the build process runs smoothly in an automated environment.
- **Package Installation**: The `RUN` command updates the package list and installs `nginx`, `mysql-server`, and `supervisor`. The cleanup step (`rm -rf /var/lib/apt/lists/*`) reduces the image size by removing temporary files.
- **Configuration**: We copy a custom `supervisord.conf` file (which weâ€™ll create next) into the container to define how Supervisord manages our services.
- **Ports**: The `EXPOSE` instruction opens ports 80 (for Nginx) and 3306 (for MySQL), making these services accessible from outside the container.
- **Entrypoint**: The `CMD` directive launches `supervisord`, which will oversee all processes within the container.

### Step 2: Configuring Supervisord

**Supervisord** is the glue that holds our multi-service environment together. It ensures that *Nginx* and *MySQL* run concurrently and can automatically restart if they fail. Create a file named `supervisord.conf` with the following content:

```ini
[supervisord]
nodaemon=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true

[program:mysql]
command=/usr/sbin/mysqld
autorestart=true
```

#### Understanding the Configuration

- **`[supervisord]` Section**: The `nodaemon=true` setting ensures Supervisord runs in the foreground, which is critical for Docker containers since they require a foreground process to stay alive.
- **`[program:nginx]` Section**: This defines the Nginx service. The `-g "daemon off;"` flag forces Nginx to run in the foreground (rather than as a background daemon), aligning with Dockerâ€™s expectations. `autorestart=true` ensures Nginx restarts if it crashes.
- **`[program:mysql]` Section**: This specifies the MySQL service, running the `mysqld` daemon. Like Nginx, itâ€™s set to restart automatically if it fails.

> Place this file in the same directory as your `Dockerfile`, as it will be copied into the container during the build process.

### Step 3: Building the Docker Image

With the `Dockerfile` and `supervisord.conf` ready, itâ€™s time to build the Docker image. Open a terminal in the directory containing these files and run:

```sh
docker build -t my_host_like_env .
```

- **`-t my_host_like_env`**: Tags the image with a descriptive name (`my_host_like_env`).
- **`.`**: Specifies the current directory as the build context, where Docker looks for the `Dockerfile`.

This command compiles the image layer by layer, installing dependencies and setting up the environment. Once complete, youâ€™ll have a reusable image ready to spawn containers.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image.png)

### Step 4: Running the Docker Container

Now, letâ€™s launch a container based on the image we built:

```sh
docker run -d --name my_container -p 80:80 -p 3306:3306 my_host_like_env
```

- **`-d`**: Runs the container in detached mode (in the background).
- **`--name my_container`**: Assigns a friendly name to the container for easy reference.
- **`-p 80:80 -p 3306:3306`**: Maps the containerâ€™s ports (80 and 3306) to the host machine, allowing external access to Nginx and MySQL.

To verify the container is running, use:

```sh
docker ps
```

You should see output similar to this:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-1.png)

This confirms the container is active and the ports are correctly mapped.

To explore the containerâ€™s internals, open a shell inside it:

```sh
docker exec -it my_container /bin/bash
```

Once inside, check the running processes with:

```sh
ps -ef
```

This command lists all active processes, confirming that both Nginx and MySQL are operational. Youâ€™ll see output similar to this:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-2.png)

Exit the container by typing `exit`.

### Step 5: Accessing and Testing Services

With the container running, letâ€™s test the services to ensure theyâ€™re functioning as expected.

#### Accessing Nginx Web Server

1. **Test Nginx with `curl`**:

   From your host machine terminal, run:

   ```sh
   curl http://localhost:80
   ```

   If successful, this retrieves Nginxâ€™s default welcome page, confirming the web server is operational. The output might look like this:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-3.png)

   You can also access the Nginx welcome page by clicking on the link provided in the output.

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-4.png)

2. **View Nginx Logs**:
   To monitor Nginx activity, check its access log:

   ```sh
   docker exec -it my_container tail -f /var/log/nginx/access.log
   ```

   This streams the log in real-time. For errors, replace `access.log` with `error.log`. Hereâ€™s an example output:

   ![Nginx Access Log](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/host-03.PNG)

   Here is the Nginx welcome page:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-5.png)

#### Accessing MySQL Database Server

1. **Connect to MySQL**:
   Access the MySQL server inside the container:

   ```sh
   docker exec -it my_container mysql -uroot -p
   ```

   When prompted for a password, press Enter (the default root password is empty or `root` in this setup). Once connected, you can run SQL commands as you would on any MySQL server. The interface will resemble this:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-6.png)

2. **View MySQL Logs**:
   Check MySQLâ€™s error log for troubleshooting:

   ```sh
   docker exec -it my_container tail -f /var/log/mysql/error.log
   ```

   This displays any errors or warnings. If query logging is enabled, you can replace `error.log` with `query.log`. Example output:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-7.png)

## Managing Services with Supervisord

Inside the container, you can use `supervisorctl` to manage the services dynamically. First, access the containerâ€™s shell:

```sh
docker exec -it my_container /bin/bash
```

Then, use these commands:

- **Check Service Status**:

  ```sh
  supervisorctl status
  ```

- **Stop a Service**:

  ```sh
  supervisorctl stop nginx
  ```

- **Start a Service**:
  ```sh
  supervisorctl start nginx
  ```

- **Restart a Service**:
  ```sh
  supervisorctl restart nginx
  ```

Hereâ€™s what the status output might look like:

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2009/images/image-8.png)

This gives you fine-grained control over the services, mimicking the flexibility of a traditional host.

## Conclusion

Congratulations! Youâ€™ve successfully set up a Docker container that emulates a traditional host environment, running Nginx and MySQL under the supervision of Supervisord. This setup is highly extensibleâ€”you can add more services, tweak configurations, or integrate additional tools as needed.

# Setting Up a Docker Container with a Read-Only File System

In the world of DevOps, ensuring the security and integrity of applications is paramount. **Docker**, a leading containerization platform, provides a powerful mechanism to achieve this through the use of `read-only` file systems. By configuring a Docker container to operate with a read-only file system, we can effectively prevent any modifications during runtime, thereby reducing the risk of unauthorized changes or accidental data corruption. In this detailed lab, weâ€™ll walk through the process of setting up such a container, explore its behavior, and verify its read-only natureâ€”all while adopting a formal tone suitable for professionals and enthusiasts alike.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2010/images/image.png)

## Why Use a Read-Only File System?

Before diving into the technical steps, letâ€™s consider the motivation behind this setup. Containers are often deployed in production environments where consistency and security are non-negotiable. A read-only file system ensures that the containerâ€™s core filesâ€”those baked into the imageâ€”cannot be altered after the container starts. This is particularly useful for `stateless` applications, where runtime data is managed **externally** (e.g., via mounted volumes or databases), and the container itself should remain immutable. By enforcing this restriction, you safeguard against potential threats, such as malicious scripts attempting to write to the file system, or even human error that might overwrite critical files.

To illustrate this concept, weâ€™ll use a practical scenario and guide you through each step with detailed explanations, complete with code snippets and verification methods.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2010/images/Read-only-img.png)

## Scenario: A DevOps Engineerâ€™s Task

Imagine youâ€™re a DevOps engineer working for a company that prioritizes security and data integrity above all else. Your manager has tasked you with deploying a set of Docker containers that must run with read-only file systems to ensure no changes can occur during their operation. Your **goal** is twofold: configure a container with this restriction and confirm that it behaves as expectedâ€”meaning no modifications to its file system are possible. Letâ€™s break this down into actionable objectives and a step-by-step process.

## Objectives

1. **Set Up a Docker Container with a Read-Only File System**: Build and configure a container that restricts all write operations to its root file system.
2. **Verify the Configuration**: Test and confirm that the file system is indeed read-only by attempting modifications and inspecting the containerâ€™s properties.

## Step-by-Step Process

Let's get started with the implementation.

### Step 1: Crafting a Docker Image

The foundation of any Docker container is its image, defined by a `Dockerfile`. This file serves as a blueprint, specifying the base image, setup instructions, and runtime behavior. Letâ€™s create a simple yet effective image for our purposes.

1. **Create a Dockerfile**  
   Start by creating a file named `Dockerfile` in an empty directory. Open it in your preferred text editor and add the following content:

   ```dockerfile
   FROM alpine:latest

   # Create a directory and add a sample file
   RUN mkdir /data && echo "This is a read-only test file" > /data/test.txt

   # Set the working directory
   WORKDIR /data

   CMD ["sh"]
   ```

   Letâ€™s unpack this:  
   - `FROM alpine:latest`: This pulls the latest version of Alpine Linux, a lightweight and secure base image ideal for minimalistic containers.  
   - `RUN mkdir /data && echo ...`: During the image build, this command creates a `/data` directory and writes a sample file, `test.txt`, containing a simple message. This file will help us test the read-only behavior later.  
   - `WORKDIR /data`: Sets the default working directory to `/data` when the container starts, making it easier to interact with our test file.  
   - `CMD ["sh"]`: Specifies that the container should launch an interactive shell (`sh`) by default, allowing us to test the file system manually.

2. **Build the Docker Image**  
   With the `Dockerfile` ready, open your terminal, navigate to the directory containing the file, and execute:

   ```sh
   docker build -t readonly-test .
   ```

   Hereâ€™s whatâ€™s happening:  
   - `docker build`: Initiates the image-building process.  
   - `-t readonly-test`: Tags the resulting image with the name `readonly-test` for easy reference.  
   - `.`: Points Docker to the current directory, where the `Dockerfile` resides.  

   Once this command completes, youâ€™ll have a custom image ready to be instantiated as a container.

### Step 2: Launching the Container with a Read-Only File System

Now that we have our image, itâ€™s time to run a container with the read-only restriction applied.

1. **Run the Docker Container**  
   Execute the following command in your terminal:

   ```sh
   docker run --rm -it --read-only readonly-test
   ```

   Breaking this down:  
   - `docker run`: Starts a new container from the specified image.  
   - `--rm`: Automatically removes the container when it exits, keeping your system clean.  
   - `-it`: Runs the container in interactive mode with a terminal, allowing you to type commands inside it.  
   - `--read-only`: The star of the showâ€”this flag mounts the containerâ€™s root file system as read-only.  
   - `readonly-test`: The name of the image we built earlier.  

   After running this, youâ€™ll find yourself inside the containerâ€™s shell, ready to test its restrictions.

2. **Test the Read-Only File System**  
   Letâ€™s attempt some write operations to see if the read-only setting holds. From within the container, try these commands:

   ```sh
   # Attempt to append to the existing file
   echo "Attempting to write to a read-only file system" >> /data/test.txt
   
   # Attempt to create a new file
   touch /data/newfile.txt
   ```

   What should happen? Both commands will fail. The shell will display error messages indicating that the file system is read-only, preventing any modifications or new file creation. This is the expected behavior and a first sign that our configuration is working.

### Step 3: Verifying the Read-Only Behavior

To be thorough, letâ€™s confirm the read-only status with both practical tests and Dockerâ€™s introspection tools.

1. **Check for Errors**  
   When you ran the commands above, you likely saw output like this:

   ```
   sh: can't create /data/test.txt: Read-only file system
   touch: /data/newfile.txt: Read-only file system
   ```

   These errors confirm that the file system rejects write attempts. For a visual reference, imagine a screenshot like this:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2010/images/readonly-01.PNG)

   This is a clear indication that the `--read-only` flag is doing its job.

2. **Inspect the Containerâ€™s Configuration**
  
   To double-check, letâ€™s use Dockerâ€™s `inspect` command to verify the read-only setting programmatically. Since the container is running interactively in your current terminal, open a new terminal window on your host machine. First, find the containerâ€™s name or ID by running:

   ```sh
   docker ps
   ```

   This lists all running containers. Note the `CONTAINER ID` or `NAMES` column for your `readonly-test` container. Then, run:

   ```sh
   docker inspect container_name | grep '"ReadonlyRootfs"'
   ```

   Replace `container_name` with the actual ID or name from `docker ps`. The output should look something like:

   ```
   "ReadonlyRootfs": true,
   ```

   This JSON snippet confirms that the `ReadonlyRootfs` property is set to `true`, aligning with our `--read-only` flag. For a visual example, see:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2010/images/readonly-02.PNG)

## Conclusion

By following these steps, youâ€™ve successfully created, launched, and verified a Docker container with a read-only file system. This setup ensures that the containerâ€™s root file system remains immutable during runtime, bolstering both security and data integrity. Whether youâ€™re protecting against malicious attacks or simply enforcing operational consistency, this technique is a valuable addition to your DevOps toolkit.


# Keeping Containers Running with Supervisor

In the world of containerization, ensuring that your applications remain operational is paramount. Containers, by design, are lightweight and ephemeral, meaning they can stop running if their primary process fails. To address this challenge, a **supervisor process**â€”also known as an **init process**â€”can be employed to manage and maintain the state of other programs within a container. In this lab, weâ€™ll dive deep into what a supervisor process is, why itâ€™s useful in containerized environments, and how to implement it effectively using a popular tool called `supervisord`. We'll walk through a detailed example of setting up a **LAMP** (Linux, Apache, MySQL, PHP) stack inside a Docker container.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/arch.drawio.svg)

* Use **supervisord** when a container runs **multiple processes** that need individual monitoring.
* Docker’s `--restart` policy only restarts the **container**, not specific services inside it.
* A supervisor can restart a **single failed service** without taking down the rest.
* It is useful when you are **not using microservices** and instead place several components (e.g., a full LAMP stack) in one container.

## Understanding the Supervisor Process

A **supervisor** process is essentially a program tasked with launching and overseeing other programs. On a traditional Linux system, the first process to startâ€”known as `PID #1`â€”is the init process. This process is responsible for initializing all other system processes and ensuring they remain operational. If a process crashes unexpectedly, the init process can restart it, maintaining system stability. This same principle can be adapted to containers, where a **supervisor** process ensures that critical applications, such as a web server or database, stay running even in the face of failure.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/flow.drawio.svg)

In containerized environments like Docker, the default behavior is to tie the containerâ€™s lifecycle to a **single main process**. If that process stops, the container stops. This can be problematic for applications that rely on multiple interdependent processesâ€”like a web server and a database running together. By introducing a supervisor process, you can manage these processes collectively, restarting them as needed and keeping the container alive.

Several tools can serve as supervisor processes inside containers, including `init`, `systemd`, `runit`, `upstart`, and `supervisord`. Among these, `supervisord` stands out for its simplicity, flexibility, and widespread use in containerized setups.

## Why Use a Supervisor Process in Containers?


Containers are designed to be minimal and focused, often running a single process per container. However, real-world applications sometimes require multiple processes to work together. For example, a web application might need a web server (like Apache), a database (like MySQL), and a scripting language runtime (like PHP) to function. Running these in separate containers is a common practice, but itâ€™s also possibleâ€”and sometimes more convenientâ€”to run them in a **single** container, especially for development or small-scale deployments.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/image.png)

Without a supervisor process, if one of these components fails, the container could stop entirely, disrupting the application. A supervisor process mitigates this risk by monitoring the health of each process and restarting any that fail. This ensures high availability and reliability, which are critical for production environments or any system where downtime is unacceptable.

## Example: Building a LAMP Stack with Supervisord

To illustrate how a supervisor process works in practice, letâ€™s walk through an example of creating a Docker container that runs a full **LAMP** stackâ€”Linux, Apache, MySQL, and PHPâ€”managed by `supervisord`. This setup is particularly useful for developers who want a self-contained environment for testing web applications.

### Step 1: Setting Up the Dockerfile

The foundation of our container is the `Dockerfile`, a script that defines how the container image is built. Weâ€™ll start with an official Ubuntu image as our base and install the necessary components: Apache for the web server, PHP for server-side scripting, MySQL for the database, and `supervisord` to manage everything.

Hereâ€™s the `Dockerfile`:

```dockerfile
# Use an official Ubuntu as a parent image
FROM ubuntu:latest



# **apache2** – Web server for serving HTTP requests.
# **php** – PHP runtime to execute PHP scripts.
# **libapache2-mod-php** – Enables Apache to process PHP files.
# **mysql-client** – MySQL command-line tool for connecting to the database.
# **supervisor** – Manages and restarts services inside the container.

# Install necessary packages (Apache, PHP, MySQL client, supervisor)
RUN apt-get update && \
    apt-get install -y apache2 php libapache2-mod-php mysql-client supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install MySQL server (choose a root password during installation)
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install mysql-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache
RUN a2enmod rewrite

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 80 3306

# Start supervisord to manage Apache and MySQL services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

Letâ€™s break this down:

- **Base Image**: We use `ubuntu:latest` as the starting point because it provides a familiar Linux environment with access to a wide range of packages.
- **Package Installation**: The `RUN` commands install Apache, PHP, the PHP module for Apache, the MySQL client, and `supervisord`. A separate command installs the MySQL server with the `DEBIAN_FRONTEND="noninteractive"` flag to avoid interactive prompts during installation.
- **Apache Configuration**: The `a2enmod rewrite` command enables the Apache rewrite module, which is useful for URL rewriting in web applications.
- **Supervisord Configuration**: We copy a custom `supervisord.conf` file (which weâ€™ll define next) into the container to tell `supervisord` how to manage our processes.
- **Ports**: We expose port 80 for HTTP traffic (Apache) and port 3306 for MySQL connections.
- **Command**: The `CMD` instruction specifies that the container should start `supervisord` with our configuration file when it launches.
`a2enmod` is not a package you install — it is a **built-in Apache command** used to enable an Apache module.

In your Dockerfile:

```
RUN a2enmod rewrite
```

This specifically enables the **rewrite** module.

Here is the short explanation you can put in a comment:

* **a2enmod rewrite** – Activates Apache’s rewrite module, needed for clean URLs and many PHP frameworks.




**“Clean URLs”** are web addresses without extra query strings or file extensions, making them easier to read and more user-friendly. For example:

* Without rewrite: `http://example.com/index.php?page=about`
* With rewrite: `http://example.com/about`

The **`rewrite` module** lets Apache internally map those clean URLs to the correct files or scripts (like `index.php`) without changing what the user sees in the browser.

It’s required by many PHP frameworks (Laravel, WordPress, etc.) because they rely on URL routing handled by PHP rather than static files.

### Step 2: Configuring Supervisord

Next, we need to create the `supervisord.conf` file in the same directory as the `Dockerfile`. This file defines how `supervisord` should manage Apache and MySQL. Hereâ€™s the configuration:

```ini
[supervisord]
nodaemon=true

[program:apache2]
command=/usr/sbin/apache2ctl -D FOREGROUND

[program:mysql]
command=/usr/bin/mysqld_safe
```

Hereâ€™s what each section means:

- **`[supervisord]`**: This section configures `supervisord` itself. The `nodaemon=true` setting ensures that `supervisord` runs in the foreground, which is necessary for Docker containers since they expect the main process to stay active.
- **`[program:apache2]`**: This section defines the Apache process. The `command` specifies how to start Apache, with the `-D FOREGROUND` flag keeping it in the foreground as required by `supervisord`.
- **`[program:mysql]`**: This section defines the MySQL process, using `mysqld_safe`, a script that starts the MySQL server and handles basic error recovery.

### Step 3: Building and Running the Container

With the `Dockerfile` and `supervisord.conf` ready, we can build the Docker image. Open a terminal in the directory containing these files and run:

```sh
docker build -t my-lamp-image .
```

This command builds an image named `my-lamp-image`. Once the build completes, start a container based on this image:

```sh
docker run -d -p 80:80 -p 3306:3306 --name lamp-container my-lamp-image
```

- **`-d`**: Runs the container in detached mode (in the background).
- **`-p 80:80 -p 3306:3306`**: Maps the containerâ€™s ports 80 and 3306 to the same ports on the host, allowing access to Apache and MySQL from outside the container.
- **`--name lamp-container`**: Names the container for easy reference.


![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/image-1.png)

At this point, your LAMP stack container is up and running, with `supervisord` managing Apache and MySQL.

### Step 4: Verifying Running Processes

To confirm that everything is working, you can check the processes running inside the container using the `docker top` command:

```bash
docker top lamp-container
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/image-2.png)

This command displays a list of processes, including their host PIDs. You should see entries for `supervisord`, `apache2`, and `mysqld`, indicating that all components are active.

### Step 5: Testing Supervisordâ€™s Restart Functionality

One of the key benefits of using `supervisord` is its ability to restart failed processes. Letâ€™s test this by manually stopping the Apache process and observing how `supervisord` responds.

First, get the process list from inside the container to find Apacheâ€™s PID:

```bash
docker exec lamp-container ps
```

This command runs the `ps` command inside the container, producing output like this:


![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/image-3.png)

Note the PID for `apache2` (in this example, 12, though it will differ in your case). Use that PID in the following command to stop Apache:

```bash
docker exec lamp-container kill <PID>
```

This sends a termination signal to the `apache2` process. Once it stops, `supervisord` detects the failure, logs the event, and restarts the process. You can view the container logs to confirm this:

```sh
docker logs lamp-container
```

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2011/images/image-4.png)

Look for entries like these:

```
... exited: apache2 (exit status 0; expected)
... spawned: 'apache2' with pid 820
... success: apache2 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

These logs show that `apache2` exited, `supervisord` spawned a new instance with a new PID (e.g., 820), and the restarted process stabilized. This demonstrates how `supervisord` ensures the container remains functional even when a process fails.

## Conclusion

Using a supervisor process like `supervisord` in Docker containers provides a robust solution for managing multiple processes and maintaining application uptime. In our LAMP stack example, `supervisord` kept Apache and MySQL running smoothly, restarting them as needed to prevent downtime. This approach is particularly valuable for complex applications that require multiple services to operate in tandem within a single container.



---
You should still use a restart policy if you want Docker to automatically restart the container itself. Foreground mode does not replace that.

# 1. How services normally run in a traditional Linux system

On a real server (Ubuntu, CentOS, etc.):

* You have **systemd** (or older init systems).
* systemd is PID 1 and is designed to manage long-running “daemon” services.

When you start Apache or MySQL on a normal Linux server:

* They **daemonize** = they fork into the background.
* systemd *expects* this behavior.
* systemd tracks the service even if it goes into the background.

Systemd knows how to:

* Track PIDs
* Read unit files
* Restart services
* Capture logs
* Wait for multiple processes
* Manage dependencies

**systemd is built to understand daemon behavior.**

---

# 2. What happens inside a Docker container

A Docker container is **NOT** a full Linux system.

Docker does **not have systemd** inside it (unless you purposely install it, which is unusual).

Inside Docker:

* PID 1 is **your application**, e.g. supervisord or Apache.
* Docker does **not** track background daemons. It only tracks the *main* PID.

Think of Docker like this:

**“I will keep the container running only as long as the main process stays alive. If PID 1 stops, the whole container stops.”**

In a normal server this job is done by systemd.
In Docker, **there is no systemd** unless you manually add it.

---

# 3. Why daemonizing breaks everything inside a container

Let’s imagine you start Apache normally inside Docker (without foreground mode).

What Apache does:

1. It starts.
2. It daemonizes → forks into the background.
3. The original Apache process exits.

Now Docker sees:

**“PID 1 has exited. The container is done.”**

So Docker instantly stops the container.

Result:

* Apache is actually still running **in the background**,
* BUT Docker thinks the container has ended,
* So Docker kills everything and stops the container completely.

This is the core reason foreground mode is required.

---

# 4. Why supervisord needs foreground processes

If Apache or MySQL daemonize:

* supervisord starts them.
* They fork into background.
* supervisord thinks:
  **“The program ended, no process to watch.”**
* supervisord cannot track or restart them.
* No logs go to supervisord.
* Docker sees the container idle and may stop it.

To avoid this:

Apache must run with:

```
-D FOREGROUND
```

MySQL must run through:

```
mysqld_safe
```

(supervisor-friendly runner)

This forces them to stay attached to supervisord.

---

# 5. Why it DOES work on normal Linux, but NOT in Docker

### Normal Linux:

* systemd is built to manage background daemons.
* systemd tracks PID files, child processes, and service lifecycles.

### Docker:

* Docker is NOT a full init system.
* Docker cannot track background daemons.
* Docker only cares about **one** process: PID 1.
* If the main process exits, the container terminates.

This is why Apache/MySQL *cannot behave like normal daemons in Docker* unless you install systemd (which is advanced and not typical).

---

# 6. Short practical summary (copy-friendly)

* On regular Linux, systemd manages background daemons correctly.
* In Docker, there is no systemd.
* If Apache/MySQL daemonize, Docker thinks the main process exited and stops the container.
* Running in foreground keeps services attached to supervisord, so they can be monitored and restarted.

---


# Building Docker Images from a Container

Building Docker images from a container involves creating a container from an existing image, making modifications, and then committing those changes to form a new image. 

In this lab, we'll learn how to create a Docker image by making changes to a container and committing those changes. We'll start with a simple example where we create a `file` in a container and then `commit` this change to form a `new image`. 


## How It Works

When we create a Docker container, it uses a `Union File-System (UFS)` mount to provide its filesystem. Any changes made to the filesystem within the container are written as new layers, which are owned by the container that created them. 

To build a new image, we start with an existing image, make changes to it by modifying the container's filesystem, and then commit these changes to form a new image. This new image can then be used to create further containers, encapsulating the changes made.

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2020/images/image-1.png?raw=true)


### How UFS Works 

- **Base Layer:** This is the original, unchanged filesystem, like a basic Linux operating system.
- **Layers:** Each time you make changes (like installing software or creating files), these changes are saved as new layers on top of the base layer.
- **Union Mount:** The union filesystem merges these layers into a single, cohesive filesystem that the container uses.

    ![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2020/images/image-2.png?raw=true)

    The above figure demonstrates how UFS works.

## Task Description
1. Create a container from the `ubuntu:latest` image and modify its filesystem by creating a file named `HelloWorld`.
2. Commit the changes made in the container to a new image named `hw_image`.
3. Remove the modified container to clean up.
4. Verify the changes by running a new container from the `hw_image` and checking the existence of the `HelloWorld` file.

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2020/images/image.png?raw=true)


## Step-By-Step Solution

### 1. **Create a container and modify its filesystem:**

Create a container from the `ubuntu:latest` image and enter the container bash:
```sh
docker run -it --name hw_container ubuntu:latest /bin/bash
```

You are now inside the container. You can start making changes to the container's filesystem as needed.

Create a file named `HelloWorld.txt` in the container:
```bash
touch HelloWorld.txt
```

Exit the container:
```bash
exit
```

### 2. **Commit the changes to a new image:**

Here we are creating a new image from our container:
```sh
docker container commit hw_container hw_image
```

We can see the new image using the following command:
```bash
docker images
```

Expected outputs:

```bash
root@e3a09282cfb53478:~/code# docker container commit hw_container hw_image
sha256:48b5ccf0a7664e7c9172845145a55a8426b5f4c0da3ff4f53ce7cba06d6f7938
```

```bash
root@e3a09282cfb53478:~/code# docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
hw_image     latest    48b5ccf0a766   17 seconds ago   78.1MB
ubuntu       latest    a04dc4851cbc   2 months ago     78.1MB
root@e3a09282cfb53478:~/code# 
```

We can see the newly created image `hw_image`.

### 3. **Remove the modified container:**

Let's delete the existing container:
```sh
docker container rm -vf hw_container
```

### 4. **Create new Container from the new Image:**

Let's create a new container from the new image that we have created and enter the bash in the new container:
```sh
docker run -it --name new_hw_container hw_image /bin/bash
```

Use the following comand to see the files:

```bash
ls
```

Expected output:

```bash
root@e3a09282cfb53478:~/code# docker run -it --name new_hw_container hw_image /bin/bash

root@1bf71ab3cdf4:/# ls
HelloWorld.txt  boot  etc   lib    media  opt   root  sbin  sys  usr
bin             dev   home  lib64  mnt    proc  run   srv   tmp  var
root@1bf71ab3cdf4:/# 
```

We can see the `HelloWorld.txt` in this container from our new image!

This output confirms that the file `HelloWorld` was successfully created in the new image, demonstrating that the modifications made in the original container were correctly committed to the new image.


### Cleanup

Remove the container and image:

```bash
docker rm  new_hw_container
docker rmi hw_image
```


## Conclusion

In this lab, we have successfully demonstrated how to create a Docker container, modify its contents, commit those changes to create a new image, and then run a new container from that image. This process is fundamental in Docker workflows, allowing for the creation of reproducible environments and consistent application deployment. By following these steps, you can ensure that your containerized applications are built and deployed with the desired configurations and modifications. This lab reinforces the importance of understanding Docker's capabilities in managing container lifecycles and image creation.

# Create and Commit an Ubuntu Container with Git Installed

This session will guide us through creating an `Ubuntu` container, installing `Git`, and committing the changes to a `new image`. Additionally, we'll learn how to set an `entrypoint` to make using the image more efficient.

## Task

We will perform the following steps:
1. Create an `ubuntu` container and open a `bash` session.
2. Install `git` inside the container and verify the git.
3. Create new `image` by using `commit`.
4. Set the `entrypoint` for the new image to make it easier to use.

## Simple Explanation of the Process
In this lab, we will start by creating a container from the `Ubuntu` image and open a `bash` session within it. Inside this container, we will install `git` and verify that the installation was successful by checking the git `version`. After exiting the container, we will commit these changes to create a new Docker image that includes `git`. We will run a container from that image.

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2021/images/image.png?raw=true)

Finally, we will set an `entrypoint` for this new image to make it easier to use git directly without needing to specify the git command each time we start a container from this image.

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2021/images/image-1.png?raw=true)



## Step-By-Step Solution

### 1. **Create an Ubuntu container and open a bash session:**
```sh
docker run -it --name image-dev ubuntu:latest /bin/bash
```
This command creates a new container named `image-dev` from the `ubuntu:latest` image and opens an interactive bash session.

### 2. **Install Git inside the container:**
```sh
apt-get update
apt-get install -y git
```
This updates the package list and installs Git in the container.

### 3. **Verify the Git installation by checking its version:**
```sh
git --version
```
Expected output:
```bash
root@09d80252b74e:/# git --version
git version 2.43.0
root@09d80252b74e:/# 
```
This command confirms that Git was installed correctly.

### 4. **Exit the container:**
```sh
exit
```
This command exits the interactive bash session and returns to the host terminal.

### 5. **Review the filesystem changes and commit these changes to create a new image:**
```sh
docker container commit -a "@poridhi" -m "Added git" image-dev ubuntu-git
```
This command commits the changes made in the `image-dev` container to a new image named `ubuntu-git` with an author tag and a commit message.

### 6. **Remove the modified container:**
```sh
docker container rm -vf image-dev
```
This command forcefully removes the `image-dev` container to clean up.

### 7. **Verify the new image by checking the Git version in a new container:**

```sh
docker container run --rm ubuntu-git git --version
```
This command runs a temporary container from the `ubuntu-git` image to verify that Git is installed correctly.

Expected Output:

```bash
root@e3a09282cfb53478:~/code# docker container run --rm ubuntu-git git --version
git version 2.43.0
root@e3a09282cfb53478:~/code# 
```

## Setting the Entrypoint to Git

### 1. **Create a new container with the entrypoint set to Git:**
```sh
docker container run --name cmd-git --entrypoint git ubuntu-git
```
This command creates a new container named `cmd-git` with the entrypoint set to `git`, showing the standard Git help and exiting.

### 2. **Commit the new image with the entrypoint:**
```sh
docker container commit -m "Set CMD git" -a "@poridhi" cmd-git ubuntu-git
```
This command commits the changes made in the `cmd-git` container to the `ubuntu-git` image. By doing so, it sets the entrypoint of the `ubuntu-git` image to the `git` command. This means that any container started from this image will automatically use `git` as its default command, simplifying the process of running Git commands within the container.

### 3. **Remove the modified container:**
```sh
docker container rm -vf cmd-git
```
This command forcefully removes the `cmd-git` container to clean up.

### 4. **Test the new image:**
```sh
docker container run --name cmd-git ubuntu-git version
```
This command runs a new container from the `ubuntu-git` image, verifying that the entrypoint is set correctly and showing the Git version:
```sh
git version 2.43.0
```

This setup ensures that any container started from the `ubuntu-git` image will automatically use Git as the entrypoint, making it easier for users to work with Git directly.



## Conclusion

In this lab, we have successfully demonstrated how to create a Docker container, install Git, commit the changes to create a new image, and set an entrypoint for the image. By following these steps, you can streamline the process of using Git within Docker containers, making it more efficient and user-friendly. This lab reinforces the importance of understanding Docker's capabilities in managing container lifecycles and customizing images to suit specific needs.



---

# CI/CD Process Using a Git-Entrypoint Container

*(with every flag explained in context)*

## Goal of the pipeline

Before building or deploying code, the pipeline must:

1. Access the source code
2. Verify the repository is clean
3. Determine the version from Git tags
4. Fail early if anything is wrong

All of this is done **without installing Git on the CI machine**.

---

## Step 1: Make the source code available to the container

### Command

```sh
docker run --rm \
  -v "$PWD:/repo" \
  -w /repo \
  ubuntu-git status
```

### What happens

| Part              | Meaning                                             |
| ----------------- | --------------------------------------------------- |
| `docker run`      | Start a temporary container                         |
| `--rm`            | Delete the container after it finishes              |
| `-v "$PWD:/repo"` | Share the current project folder with the container |
| `-w /repo`        | Run commands inside the shared folder               |
| `ubuntu-git`      | Image whose ENTRYPOINT is `git`                     |
| `status`          | Run `git status`                                    |

### In plain words

> “Run Git inside a container, using my current project directory.”

Without `-v`, Git would see **no files**.
Without `-w`, Git would run in `/` and fail.

---

## Step 2: Ensure there are no uncommitted changes

### Command

```sh
docker run --rm \
  -v "$PWD:/repo" \
  -w /repo \
  ubuntu-git status --porcelain
```

### Why `--porcelain` is used

| Flag          | Purpose                          |
| ------------- | -------------------------------- |
| `status`      | Check working tree state         |
| `--porcelain` | Output in script-friendly format |

### CI logic

* If output is **empty** → repository is clean
* If output has **any lines** → fail the pipeline

### Why CI cares

CI/CD must build **only committed code**.
Uncommitted files mean the build is not reproducible.

---

## Step 3: Generate a version string from Git

### Command

```sh
docker run --rm \
  -v "$PWD:/repo" \
  -w /repo \
  ubuntu-git describe --tags --dirty
```

### Explanation of each part

| Element    | Purpose                                   |
| ---------- | ----------------------------------------- |
| `describe` | Generate a version from Git history       |
| `--tags`   | Use Git tags                              |
| `--dirty`  | Mark version if uncommitted changes exist |

### Example outputs

Clean repo:

```text
v1.2.3
```

Dirty repo:

```text
v1.2.3-dirty
```

### Why this matters in CI/CD

* Prevents releasing code that differs from Git history
* Makes builds traceable to commits

---

## Step 4: Extract only the release version (tag)

### Command

```sh
docker run --rm \
  -v "$PWD:/repo" \
  -w /repo \
  ubuntu-git describe --tags --abbrev=0
```

### Why `--abbrev=0`

| Flag         | Purpose                      |
| ------------ | ---------------------------- |
| `--abbrev=0` | Output **only the tag name** |

### Example output

```text
v1.2.3
```

This value is commonly used for:

* Docker image tags
* Release names
* Deployment versions

---

## Step 5: Use the version in the build

### Example CI logic

```sh
VERSION=$(docker run --rm \
  -v "$PWD:/repo" \
  -w /repo \
  ubuntu-git describe --tags --abbrev=0)

docker build -t my-app:$VERSION .
```

### What this achieves

* Version comes directly from Git
* No manual versioning
* Every build is traceable

---

## Why ENTRYPOINT = `git` matters here

Because the image behaves like the Git binary:

```sh
ubuntu-git describe --tags
```

instead of:

```sh
ubuntu-git git describe --tags
```

This:

* Reduces mistakes
* Improves readability
* Makes the container a **single-purpose tool**

---

## Final mental model

Think of this as:

> “I am running Git, but Git happens to live inside a container.”

Not:

> “I am running a Linux system.”

---





# Reviewing Filesystem Changes in Docker

Docker lets you track filesystem changes inside containers using the `docker container diff` command. Changes can be **added (A), changed (C), or deleted (D)**.

### Key Concepts

* **Union filesystem (UFS):** Files are read from the topmost layer where they exist.
* **Copy-on-write:** Modifying a file in a read-only layer copies it to the writable layer first.

### Tasks & Commands

1. **Add a file:**

```sh
docker container run --name tweak-a busybox:latest touch /HelloWorld
docker container diff tweak-a
# Output: A /HelloWorld
```

2. **Delete a file:**

```sh
docker container run --name tweak-d busybox:latest rm /bin/vi
docker container diff tweak-d
# Output: C /bin
#         D /bin/vi
```

3. **Change a file:**

```sh
docker container run --name tweak-c busybox:latest touch /bin/vi
docker container diff tweak-c
# Output: C /bin
#         C /bin/vi
```

4. **Clean up containers:**

```sh
docker container rm -vf tweak-a tweak-d tweak-c
```

**Summary:** `docker container diff` shows changes to the filesystem, helping debug and manage containerized applications effectively.

---


# Modifying Docker Image Attributes

This lab aims to deepen your understanding of Docker image attributes and how they can be modified and inherited across different layers of an image. 

By the end of this exercise, you will be familiar with setting environment variables, working directories, exposed ports, volume definitions, container entrypoints, and commands.


When you use docker container commit, you create a new layer for an image. This layer includes not only a snapshot of the filesystem but also metadata about the execution context. The following parameters, if set for a container, will be carried forward to the new image:

- Environment variables
- Working directory
- Exposed ports
- Volume definitions
- Container entrypoint
- Command and arguments

If these parameters are not explicitly set, they will be inherited from the original image.

This lab will provide you with hands-on experience in modifying these attributes and observing how they are inherited across image layers.

## Task Description

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2023/images/image.png?raw=true)


**Create a Container with Environment Variables**
- Run a Docker container from the `busybox:latest` image, setting two environment variables.
- Commit the running container to a new image.

**Modify the Entrypoint and Command**
- Run a new container from the previously committed image, setting a new entrypoint and command.
- Commit this container to update the image.

**Verify Inheritance of Attributes**
- Run a container from the final image without specifying any command or entrypoint to verify that the environment variables and the entrypoint/command are inherited correctly.



## Solution Steps

### **Create a Container with Environment Variables**

- Run the container:
    ```bash
    docker run --name container1 -e ENV_EXAMPLE1=value1 -e ENV_EXAMPLE2=value2 busybox:latest
    ```

    This command creates a new container named `container1` from the `busybox:latest` image and sets two environment variables, `ENV_EXAMPLE1` and `ENV_EXAMPLE2`.

    Expected output:

    ```
    term@ubuntu-x1brs3-5444b5f5fc-j5xpq:~$ docker run --name container1 -e ENV_EXAMPLE1=value1 -e ENV_EXAMPLE2=value2 busybox:latest

    Unable to find image 'busybox:latest' locally
    latest: Pulling from library/busybox
    ec562eabd705: Pull complete 
    Digest: sha256:9ae97d36d26566ff84e8893c64a6dc4fe8ca6d1144bf5b87b2b85a32def253c7
    Status: Downloaded newer image for busybox:latest
    ```

- Commit the container to a new image:
    ```bash
    docker commit container1 new-image
    ```

    This command commits the `container1` container to a new image named `new-image`.

    Varify the image creation using the following command:

    ```bash
    docker images
    ```

    Expected output:

    ```bash
    root@e3a09282cfb53478:~/code# docker images
    REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
    new-image    latest    24811125c10b   34 seconds ago   4.28MB
    busybox      latest    ff7a7936e930   6 months ago     4.28MB
    root@e3a09282cfb53478:~/code# 
    ```


### **Modify the Entrypoint and Command**

- Run a new container with a specific entrypoint and command:
    ```bash
    docker run --name container2 --entrypoint "/bin/sh" new-image -c "echo \$ENV_EXAMPLE1 \$ENV_EXAMPLE2"
    ```

    This command runs a new container named `container2` from the `new-image` image, setting the entrypoint to `/bin/sh` and the command to `-c "echo \$ENV_EXAMPLE1 \$ENV_EXAMPLE2"`. This setup will print the values of the environment variables.

    Expected output:

    ```bash
    root@e3a09282cfb53478:~/code# docker run --name container2 --entrypoint "/bin/sh" new-image -c "echo \$ENV_EXAMPLE1 \$ENV_EXAMPLE2"
    value1 value2
    root@e3a09282cfb53478:~/code# 
    ```


- Commit this container to update the image:
    ```bash
    docker commit container2 new-image
    ```
    This will commit the container `container2` to the `new-image` image, updating the image with the new entrypoint and command. The updated image will have the entrypoint and the command with it.

- Verify the new image's entrypoint and command settings:
    ```bash
    docker inspect --format '{{ .Config.Entrypoint }}' new-image

    docker inspect --format '{{ .Config.Cmd }}' new-image
    ```

    Expected output:

    ```bash
    root@e3a09282cfb53478:~/code# docker inspect --format '{{ .Config.Entrypoint }}' new-image

    [/bin/sh]

    root@e3a09282cfb53478:~/code# docker inspect --format '{{ .Config.Cmd }}' new-image

    [-c echo $ENV_EXAMPLE1 $ENV_EXAMPLE2]
    ```

### **Verify Inheritance of Attributes**

- Run a container from the final image to verify the inherited behavior:
    ```bash
    docker run --rm new-image
    ```

    This command runs a container from the final `new-image` image, verifying that the environment variables and the entrypoint/command are inherited correctly. 

    Expected output:

    ```bash
    root@e3a09282cfb53478:~/code# docker run --rm new-image
    value1 value2
    root@e3a09282cfb53478:~/code#
    ```


## Conclusion

By completing this lab, we hope, you have a practical understanding of how to modify and verify Docker image attributes, and how these changes are inherited across image layers.

# Exploring Docker Image Layers and Size Management

Docker images are built from layers, where each layer represents a set of filesystem changes. The size of an image on disk is the sum of the sizes of its component layers. Docker allows you to commit changes to a running container, creating new image layers. 

This lab will guide you through these concepts with hands-on practices, focusing on creating and modifying a Docker image with ubuntu as the base image. You will install and remove software within containers, observe the changes in image sizes, and understand the impact of Docker's Union File System (UFS) on image size. 

![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2024/images/image.png?raw=true)

## Task Description

### Building and Modifying Docker Images

Here, you will create a Docker image from the official Ubuntu image, install Git within a container, and commit the changes to create a new image. You will then modify this image by removing Git and observe how Docker manages image layers and size. 

## Step-By-Step Solution

### **Pull the Ubuntu Image:**

Pull the `ubuntu` image from Docker Hub.
```sh
docker pull ubuntu
```
This command fetches the latest `ubuntu` image from Docker Hub and stores it in your local Docker repository.

### **Create a Container and Install Git:**

Create a container from the `ubuntu` image and install Git.
```sh
docker run -d --name ubuntu-git-container ubuntu sleep infinity
docker exec -it ubuntu-git-container apt-get update
docker exec -it ubuntu-git-container apt-get install -y git
```
These commands run a container named `ubuntu-git-container` from the `ubuntu` image and install Git inside the container. The `sleep infinity` command keeps the container running. The `apt-get update` and `apt-get install -y git` commands update the package list and install Git, respectively.

### **Commit the Changes to Create a New Image:**

Commit the container to create a new image with Git installed.
```sh
docker commit ubuntu-git-container ubuntu-git:1.0
docker tag ubuntu-git:1.0 ubuntu-git:latest
```
These commands commit the current state of the `ubuntu-git-container` container to a new image named `ubuntu-git` with a tag `1.0`, and then tag this image as `latest`.


### **Check Image Sizes:**

Check the sizes of all the images created.
```sh
docker images
```

Expected output:

```bash
root@e3a09282cfb53478:~/code# docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
ubuntu-git   1.0       193ae1feaeea   6 seconds ago    125MB
ubuntu-git   latest    193ae1feaeea   6 seconds ago    125MB
ubuntu       latest    a04dc4851cbc   2 months ago     78.1MB
root@e3a09282cfb53478:~/code# 
```

### **Remove Git:**

Create a new container from the `ubuntu-git` image and remove Git.
```sh
docker run --name ubuntu-git-remove --entrypoint /bin/bash ubuntu-git:latest -c "apt-get remove -y git"
```
This command runs a container named `ubuntu-git-remove` from the `ubuntu-git:latest` image with an entrypoint set to `/bin/bash`, and removes Git from the container.

### **Commit the Changes to Create a New Image with Git Removed:**

Commit the container to create a new image with Git removed.
```sh
docker commit ubuntu-git-remove ubuntu-git:2.0
docker tag ubuntu-git:2.0 ubuntu-git:latest
```
These commands commit the current state of the `ubuntu-git-remove` container to a new image named `ubuntu-git:removed` and reassign the `latest` tag to this new image.


### **Check Image Sizes:**

Check the sizes of all the images created.
```sh
docker images
```

Expected output:

```bash
root@e3a09282cfb53478:~/code# docker images
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
ubuntu-git   2.0       8a9686de5a78   9 seconds ago        125MB
ubuntu-git   latest    8a9686de5a78   9 seconds ago        125MB
ubuntu-git   1.0       193ae1feaeea   About a minute ago   125MB
ubuntu       latest    a04dc4851cbc   2 months ago         78.1MB
root@e3a09282cfb53478:~/code#
```



Notice that even though you removed Git, the image actually same in size.
 Although you could examine the specific changes with `docker diff`, you should be
 quick to realize that the reason for the increase has to do with the union file system.

 Remember, UFS will mark a file as deleted by actually adding a file to the top layer.
 The original file and any copies that existed in other layers will still be present in the
 image.  When a file is deleted, a delete record is written to the top layer, which overshadows
 any versions of that file on lower layers.
 
 Itâ€™s important to minimize image size for the sake of the people and systems
 that will be consuming your images. If you can avoid causing long download times and
 significant disk usage with smart image creation, then your consumers will benefit.



 # A Deeper Look into Node.js Docker Images

Node.js Docker images come in various flavours, each tailored for specific use cases. Picking the right image for your application can be challenging, as it involves balancing factors such as size, security vulnerabilities, and functionality. This document explores the differences among popular Node.js Docker images, highlighting their pros and cons to help developers make informed choices.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2029/images/banner%20.svg)

## Objective

This documentation aims to:

- Compare various Node.js Docker image variants.
- Analyse their composition and intended use cases.
- Provide recommendations for choosing the right image based on development and production needs.


## Table of Contents

- [Node.js Releases and Selection Criteria](#nodejs-releases-and-selection-criteria)
- [Basic Comparison of Available Images](#basic-comparison-of-available-images)
- [Overview of Each Image](#overview-of-each-image)
  - [Official Docker Images](#official-docker-images)
  - [Bitnami Images](#bitnami-images)
  - [GoogleContainerTools Distroless](#googlecontainertools-distroless)
  - [Chainguardâ€™s Distroless](#chainguards-distroless)
- [Conclusion and Recommendations](#conclusion-and-recommendations)


## Node.js Releases and Selection Criteria

Node.js recommends using Active LTS or Maintenance LTS releases for production applications. Active LTS versions are considered stable and ready for general use, while Maintenance LTS ensures critical bug fixes for an extended period.

![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2029/images/image.png)

###  Release Lifecycle

- **Current Release:** Supported for six months after release, intended for library authors and early adopters.

- **Active LTS:** Stable and reliable, with extended support for 30 months. Suitable for production.

- **Maintenance LTS:** Focused on critical fixes, suitable for older but still functional production environments.


## Basic Comparison of Available Images

### Official Docker Images

In the official Node.js Docker images, the `node` tag is used to specify the version of Node.js. The `node` tag is followed by the version number, which corresponds to the Node.js release. Here are some examples:

```bash
docker pull node:22
docker pull node:22-slim
docker pull node:22-alpine
```

### Bitnami Images

Bitnami repacks the Node.js binary with additional dependencies and tools. 

```bash
docker pull bitnami/node:22
```

### GoogleContainerTools Distroless

GoogleContainerTools Distroless images are minimalistic images that only contain the Node.js binary and its dependencies. They are designed to be used in production environments where security and size are critical.

```bash
docker pull gcr.io/distroless/nodejs22-debian12
```

### Chainguardâ€™s Distroless

Chainguardâ€™s Distroless images are similar to GoogleContainerTools Distroless images, but they are built on top of the Chainguard base image.

```bash
docker pull cgr.dev/chainguard/node:latest
```

Simply listing the pulled images can already give us some initial food for thought:

```bash
docker images
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2029/images/image-2.png)

If we observe the images, we can see that the `node:22` image is the largest image with `1.2GB` in size, followed by lower size image `gcr.io/distroless/nodejs22-debian12` with `143MB` in size.

## Overview of Each Images

### `node:22`

If we look at the `node:22` image, we can see that it is the largest image of the lot. It is 1.2GB in size. It has a full-fledged Python installation inside.

If we run the following command, we can see that the Python installation is indeed present.

```bash
docker run --entrypoint bash node:22 -c 'python3 --version'
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2029/images/image-3.png)

Interesting is that Python is not the only "unexpected" package in this image - for instance, this image also includes the entire GNU Compiler Collection:

```bash
docker run --entrypoint bash node:22 -c 'gcc --version'
```

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2029/images/image-4.png)

If we inspect the package list, we can see that the `node:22` image includes a variety of packages

```bash
# Download latest release
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
syft node:22
```
![alt text](https://github.com/poridhiEng/lab-asset/blob/main/Docker%20Labs/Lab%2029/images/images-5.png?raw=true)

And, of course, with so many packages comes with lot of CVEs. `CVEs` are a list of security vulnerabilities that have been discovered in the software.

```bash
trivy image -q node:22
```

All the packages are not always necessary for the Node.js application to run. That is why we have the `node:22-slim` and `node:22-alpine` images.

### Why `node:22` has so many bloated packages?

The `node:<version>` image has so many bloated packages because it is based on `buildpack-deps`, which includes a wide range of commonly used `Debian` packages. These packages are included to support various development needs, such as `Python`, `GCC`, and other tools required for building or compiling software. While this design reduces the need to install additional packages in derived images, it significantly increases the size of the base image, making it less suitable for lightweight production environments.




# **Extracting Container Image Filesystem Using Docker**

In this lab,  we will learn how to extract the filesystem of a Docker container image using different methods and understand their trade-offs.

![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2030/images/1.svg)



## **Prerequisites**
- Docker installed on your system (version 18.09+ recommended).
- Basic understanding of Docker commands.
- A Linux-based operating system or Docker Desktop.
- Access to the internet to pull Docker images.



## **Lab Steps**

### **1. Setting Up**
1. Verify your Docker installation:
   ```bash
   docker --version
   ```
2. Pull the target container image:
   ```bash
   docker pull nginx:alpine
   ```



### **2. Method 1: Using `docker save`**

`docker save` produces a tarball containing image layers and metadata but not a complete filesystem. This method is ideal for transferring or archiving images.

1. Use the `docker save` command to export the image:
   ```bash
   docker save nginx:alpine -o nginx_alpine.tar
   ```
2. Extract the `.tar` file:
    ```bash
    mkdir image_layers
    tar -xf nginx_alpine.tar -C image_layers
    ```
3. Explore the extracted layers:
   ```bash
   ls -l image_layers
   ```

    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2030/images/image.png)




### **3. Method 2: Using `docker export`**

`docker export` extracts the filesystem of a container in its current state, excluding Docker-specific metadata (e.g., image layers). It's useful for obtaining a clean snapshot of the container's filesystem.

1. Start a container:
   ```bash
   CONT_ID=$(docker run -d nginx:alpine)
   ```
2. Export the filesystem:
   ```bash
   docker export ${CONT_ID} -o nginx_fs.tar.gz
   ```
3. Extract the `.tar` file:
   ```bash
    mkdir nginx_rootfs
    tar -xf nginx_fs.tar.gz -C nginx_rootfs
   ```
4. Explore the filesystem:
   ```bash
   ls -l nginx_rootfs
   ```

    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2030/images/image-1.png)

    Tip: Stop and remove the container after this step:

    ```bash
    docker rm -f ${CONT_ID}    
    ```




### **4. Method 3: Using `docker create + docker export`**

Using `docker create` avoids starting the container, creating a lightweight placeholder for exporting its filesystem. This method is useful when you don't need to execute any processes within the container.

1. Create a container without starting it:
   ```bash
   CONT_ID=$(docker create nginx:alpine)
   ```
2. Export the filesystem:
   ```bash
   docker export ${CONT_ID} -o nginx_fs.tar.gz
   ```
3. Extract the `.tar` file:
   ```bash
    mkdir nginx_rootfs
    tar -xf nginx_fs.tar.gz -C nginx_rootfs
   ```
4. Explore the filesystem:
   ```bash
   ls -l nginx_rootfs
   ```

    ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2030/images/image-2.png)

5. **Cleanup:**
   ```bash
   docker rm ${CONT_ID}
   ```
6. **Observation:** This method avoids starting a container, preserving the original filesystem structure.






### **5. Method 4: Using `ctr image mount`**

`containerd` is the runtime underlying Docker. Using `ctr`, you can directly mount image layers as a unified filesystem. This is efficient for temporary exploration without exporting.



1. Install `ctr` (containerd CLI) if not already installed.
2. Pull the image using `ctr`:
   ```bash
   sudo ctr image pull docker.io/library/nginx:alpine
   ```
3. Mount the image filesystem:
   ```bash
   mkdir nginx_rootfs
   sudo ctr image mount docker.io/library/nginx:alpine nginx_rootfs
   ```
4. Explore the filesystem:
   ```bash
   ls -l nginx_rootfs
   ```
5. **Cleanup:**
   ```bash
   sudo umount ginx_rootfs
   ```



## **Comparison of Methods**
| Method                    | Pros                                    | Cons                                      |
|---------------------------|-----------------------------------------|-------------------------------------------|
| `docker save`             | Simple to use                          | Exports layers, not the final filesystem. |
| `docker export`           | Exports filesystem of a running container | Requires starting a container.           |
| `docker create + export`  | Avoids running a container              | Some small artifacts may still exist.    |
| `docker build -o`         | Accurate filesystem representation     | Requires BuildKit and might lose ownership metadata. |
| `ctr image mount`         | Artifact-free filesystem export         | Requires containerd and additional setup.|


## **Conclusion**
In this lab, you explored multiple methods to extract the filesystem of a Docker image. Each method has its use case, and the choice depends on your requirements for accuracy, speed, and security.



---

# Containerizing a Node.js App (Short Version)

### 1. Containerization

* Packages app + dependencies into a **portable container**.
* Ensures **consistency** across environments.

### 2. Dockerfile Basics

* Text file with instructions to build a Docker image.
* Each instruction creates a **layer** that can be cached.

### 3. Example Node.js App

```javascript
const http = require('http');
const hostname = '0.0.0.0', port = 8000;
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});
server.listen(port, hostname);
```

### 4. Dockerfile

```dockerfile
FROM node:14-alpine
WORKDIR /usr/src/app
COPY app.js .
RUN npm install http@0.0.1-security
EXPOSE 8000
CMD ["node", "app.js"]
```

* `WORKDIR` sets the **container path**, not relative to host.
* `COPY` copies app files to container.
* `EXPOSE` defines the app port.
* `CMD` starts the app.

### 5. Build & Run

```bash
docker build -t my-node-app:1.0 .
docker run -d --name my-node-app-container -p 80:8000 my-node-app:1.0
```

* `-t` tags the image (`name:tag`).
* `-p host:container` maps ports.
* `-d` runs in background.

### 6. Optional: Push to Docker Hub

```bash
docker tag my-node-app:1.0 your-docker-id/my-node-app:1.0
docker push your-docker-id/my-node-app:1.0
```

### 7. Docker Layers

* Each Dockerfile instruction is a layer.
* Layers are cached; changes to later layers **don’t rebuild earlier ones**.

### 8. Multi-Stage Build (Optional for Optimization)

```dockerfile
# Stage 1: Build
FROM node:14 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build   # produces /app/dist

# Stage 2: Production
FROM node:14-alpine
WORKDIR /app
COPY --from=builder /app/dist .   # only copy build output
CMD ["node", "app.js"] 

```

* Useful if **build tools/dependencies** can be discarded in final image.
* Reduces image size for production.

### Key Takeaways

* Multi-stage builds **help reduce image size** if build tools are heavy.
* For small apps with minimal dependencies, single-stage is enough.
* Always use **absolute paths** for `WORKDIR` inside containers.
* Use `-t` to **tag images**, `:` separates name and version.

---

 


---

## Lab Overview

In this lab, you will:

* Understand core Docker Compose concepts such as **services**, **networks**, and **volumes**
* Build and deploy a **multi-container Flask + Redis application**
* Verify application functionality
* Interact with common Docker Compose commands
* Clean up Docker resources after use

---

## Key Concepts

Before starting the hands-on section, review the main components you will work with.

### Services

A **service** in Docker Compose defines how a container is built and run. Services can be created from a Dockerfile or pulled from an existing image. Each service runs in its own container.

### Networks

Docker Compose automatically creates a default network that allows services to communicate using service names. You can define custom networks to explicitly control communication between services.

### Volumes

**Volumes** provide persistent storage. Data stored in a volume remains available even if containers are stopped or removed, making volumes suitable for data that must be preserved.

---

## Hands-On: Deploy a Multi-Container Application with Docker Compose

### Step 1: Set Up the Project Structure

Create a new directory for the project:

```bash
mkdir multi-container
cd multi-container
```

This directory will contain all application and configuration files.

---

### Step 2: Create the Flask Application (`app.py`)

Create a file named `app.py` inside the `multi-container` directory:

```python
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return f'Hello World! This page has been visited {count} times.\n'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
```

This application uses Redis to track how many times the root URL (`/`) has been accessed. Flask serves the application on port `8000`.

---

### Step 3: Create the Dockerfile

Create a file named `Dockerfile` in the same directory:

```dockerfile
FROM python:3.9-alpine
WORKDIR /app
COPY . /app
RUN pip install flask redis
EXPOSE 8000
CMD ["python", "app.py"]
```

This Dockerfile:

* Uses a lightweight Python base image
* Sets `/app` as the working directory
* Copies application files into the container
* Installs required Python packages
* Exposes port `8000`
* Starts the Flask application

---

### Step 4: Create the Docker Compose File (`docker-compose.yml`)

Create a `docker-compose.yml` file:

```yaml
version: "3.8"

services:
  web-fe:
    build: .
    command: python app.py
    ports:
      - target: 8000
        published: 5001
    networks:
      - counter-net
    volumes:
      - type: volume
        source: counter-vol
        target: /app

  redis:
    image: redis:alpine
    networks:
      - counter-net

networks:
  counter-net:

volumes:
  counter-vol:
```

#### What this configuration does

**web-fe (Flask application):**

* Built from the current directory
* Accessible on `localhost:5001`
* Connected to a custom network (`counter-net`)
* Uses a persistent volume (`counter-vol`)

**redis:**

* Uses the official Redis Alpine image
* Connected to the same network as the Flask service

---

### Step 5: Deploy the Application

Build and start the application in detached mode:

```bash
docker-compose up -d
```

This command:

* Creates the custom network and volume
* Builds the Flask image
* Starts both containers in the background

---

### Step 6: Verify the Deployment

#### Check Running Services

```bash
docker-compose ps
```

You should see both `web-fe` and `redis` running.

#### View Application Logs

```bash
docker-compose logs
```

Check for successful startup messages or errors.

#### Access the Application

Open port `5001` from Poridhi’s VS Code environment or test using `curl`:

```bash
curl localhost:5001
```

You should see a response indicating how many times the page has been visited. Repeating the request will increment the count.

---

### Step 7: Inspect the Running Containers

View the processes running inside each container:

```bash
docker-compose top
```

---

### Step 8: Verify Volumes and Networks

List Docker volumes:

```bash
docker volume ls
```

List Docker networks:

```bash
docker network ls
```

You should see `counter-vol` and `counter-net` in the output.

---

## Cleanup

When you are finished, remove all resources created by Docker Compose:

```bash
docker-compose down --volumes
```

This command stops and removes the containers, deletes the network, and removes the volume.

---



---

## 1. How Docker handles **named volumes** when mounted over a container path

When you declare:

```yaml
volumes:
  - counter-vol:/app
```

Docker does the following **at container startup**:

1. It checks if `counter-vol` exists:

   * **If it exists:** it simply mounts the volume over `/app`.
   * **If it does not exist:** it **initializes the volume**.

2. **Important:** Initialization **does not automatically copy the image contents** into the volume unless you use `docker cp` or a similar mechanism.

   * This is a key difference between **named volumes** and **bind mounts**.
   * Named volumes are empty by default when first created, so `/app` from the image becomes hidden because the volume is mounted on top of it.

---

## 2. Why the Flask code becomes “invisible”

* Your Dockerfile put `app.py` in `/app`.

* When you mount a **new named volume** at `/app`, Docker overlays it.

* Docker does **not** copy `/app` contents into `counter-vol` automatically.

* Therefore, at first container startup:

  ```
  /app inside container = empty (volume)
  ```

* Only data **written after container starts** will persist in `counter-vol`.

This is why I said the code becomes invisible — it’s literally **hidden behind the empty volume**.

---

## 3. Contrast with databases

* Redis (or MySQL) writes runtime data to `/data` inside the container.

* Mounting a volume there is perfect because:

  * The container does **not** need pre-existing files from the image
  * All files written there **persist** to the volume

* For Flask code:

  * Files are needed **at startup**
  * A named volume at `/app` hides them
  * Container fails unless you copy them manually

---

## 4. When would the volume contain your app code?

1. If you manually copy the code into the volume at startup (e.g., an entrypoint script)
2. If you use a **bind mount** to a host folder (`.:/app`) in development

   * Here the host directory already has your code, so `/app` is populated
3. If the volume was previously populated with `/app` from a container (Docker can populate it if the volume was created via `docker cp` or manually)

**Otherwise:** the volume starts empty.

---

### ✅ Key takeaway

* **Named volume** = initialized empty unless explicitly populated
* Mounting it over `/app` **hides your image contents** at startup
* For databases: works perfectly because data is runtime-generated
* For static app code: does **not** work, because the container relies on the image for `/app`

---




--- 

# Deploying a Monitored NGINX Web Server Using Docker (Using Docker Networks)

In this example, you will learn how to use Docker to install and manage a web server using NGINX, set up a monitoring system, and configure alert notifications using **Docker user-defined networks**. This approach replaces deprecated container linking and enables built-in DNS-based service discovery.

## Task Description

We are going to create a new website that requires close monitoring. We will use NGINX for the web server and want to receive email notifications when the server goes down. The architecture will consist of three containers connected through a Docker network:

1. **Web Container**: Runs the NGINX web server
2. **Mailer Container**: Sends email notifications
3. **Agent Container**: Monitors the web server and triggers the mailer when the server is down

All containers will communicate using container names as hostnames over a user-defined bridge network.

---

## Creating a Docker Network

### Step 0: Create a User-Defined Network

```bash
docker network create monitor-net
```

This network:

* Provides automatic DNS-based name resolution
* Replaces legacy `--link` functionality
* Improves isolation and scalability

All containers in this lab will be attached to `monitor-net`.

---

## Creating and Starting Containers

### Step 1: Start NGINX Container

Download, install, and start an NGINX container in detached mode on the network:

```bash
docker run -d --name web --network monitor-net nginx:latest
```

This command:

* Downloads the latest NGINX image
* Creates a container named `web`
* Attaches it to the `monitor-net` network

The service will be reachable at hostname `web` by other containers on the same network.

---

### Step 2: Create and Start Mailer Container

Create a directory for the mailer:

```sh
mkdir mailer
cd mailer
```

Create the `mailer.sh` script:

```sh
touch mailer.sh
```

Edit `mailer.sh`:

```sh
#!/bin/sh
printf "CH2 Example Mailer has started.\n"
while true
do
        MESSAGE=`nc -l -p 33333`
        printf "Sending email: %s\n" "$MESSAGE"
        sleep 1
done
```

Create the `Dockerfile`:

```Dockerfile
# Use BusyBox as the base image (very small Linux environment)
FROM busybox

# Copy all files from the build context into /mailer inside the image
COPY . /mailer

# Set /mailer as the working directory for subsequent commands
WORKDIR /mailer

# Create a non-root user named "example"
# -D : create user with default settings (no password)
# -H : do not create a home directory
# -s : set the user's login shell to /bin/sh
RUN adduser -DHs /bin/sh example

# BusyBox images → use /bin/sh
# Bash is not available unless explicitly installed

# Change ownership of the mailer script to the "example" user
RUN chown example mailer.sh

# Make the mailer script executable
RUN chmod a+x mailer.sh

# Document that the container listens on TCP port 33333
# (this does not open the port by itself)
EXPOSE 33333

# Switch to the non-root user for all subsequent commands
USER example

# Run the mailer script when the container starts
CMD ["/mailer/mailer.sh"] 
```

Build the image:

```bash
docker build -t mailer-image .
```

Run the mailer container on the network:

```bash
docker run -d --name mailer --network monitor-net mailer-image
```

---

## Running Interactive Containers

### Step 3: Start an Interactive Container for Testing

Run an interactive BusyBox container on the same network to verify connectivity:

```bash
docker run -it --name web_test --network monitor-net busybox:latest /bin/sh
```

Inside the container, run:

```sh
wget -O - http://web:80/
```

You should see the **NGINX welcome page**, confirming:

* Network connectivity
* DNS resolution by container name

Exit the shell:

```sh
exit
```

---

## Monitoring and Notifications

### Step 4: Start the Agent Container

Create a directory for the watcher:

```sh
mkdir watcher
cd watcher
```

Create the `watcher.sh` script:

```sh
touch watcher.sh
```

Edit `watcher.sh`:

```sh
#!/bin/sh
while true
do
        if printf "GET / HTTP/1.0\n\n" | nc -w 2 web 80 | grep -q "200 OK"
        then
                echo "System up."
        else
                printf "To: admin@work Message: The service is down!" | nc mailer 33333
                break
        fi
        sleep 1
done
```

Key changes:

* Uses container names (`web`, `mailer`) instead of environment variables
* Relies on Docker’s embedded DNS

Create the `Dockerfile`:

```Dockerfile
FROM busybox
COPY . /watcher
WORKDIR /watcher

RUN adduser -DHs /bin/sh example
RUN chown example watcher.sh
RUN chmod a+x watcher.sh

USER example
CMD ["/watcher/watcher.sh"]
```

Build the agent image:

```bash
docker build -t watcher-image .
```

Run the agent container on the network:

```bash
docker run -it --name agent --network monitor-net watcher-image
```

This container will:

* Continuously check the web server
* Print “System up.”
* Notify the mailer if the web service goes down

Detach using:

```
Ctrl + P, Ctrl + Q
```

---

## Managing Containers

### Step 5: List Running Containers

```bash
docker ps
```

---

### Step 6: Restart Containers

```bash
docker restart web
docker restart mailer
docker restart agent
```

---

### Step 7: View Container Logs

```bash
docker logs web
docker logs mailer
docker logs agent
```

Expected output:

* **Web**: HTTP requests
* **Mailer**: “CH2 Example Mailer has started.”
* **Agent**: Repeated “System up.”

---

### Step 8: Follow Logs in Real Time

```bash
docker logs -f agent
```

Press `Ctrl + C` to stop.

---

### Step 9: Test the Monitoring System

Stop the web server:

```bash
docker stop web
```

Check mailer logs:

```bash
docker logs mailer
```

Expected output:

```
Sending email: To: admin@work Message: The service is down!
```

---

## Conclusion

You have successfully implemented a Docker-based monitoring system using **user-defined networks instead of deprecated container linking**. This approach is scalable, secure, and aligned with modern Docker practices. You now understand how containers discover each other via DNS, how to monitor services, and how to react to failures automatically.
