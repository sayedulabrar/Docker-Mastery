# 🐳 Docker & Linux Command Notes

## 🚀 Docker Basics

### **Build Image**
```bash
docker build -t hello-world .
```
- `-t` → Tag name for the image  
- `.` → Location of the Dockerfile

> ⚠️ Avoid using `docker commit` — it’s only for testing, **not for production**.

---

### **Run Container (Recommended Way)**
```bash
docker run -d --name node-app --network internal -p 4000:4000 my-node-app
```
- `-d` → Run in detached mode (background)  
- `--name` → Assign a name to the container  
- `-p` → Map host port to container port  

---

### **Push Image to Docker Hub**
```bash
docker tag hello-world toky/hello-world
docker push toky/hello-world
```

### **Pull and Run on Another Machine**
```bash
docker pull toky/hello-world
docker run -d --name hello-world -p 4000:4000 toky/hello-world
```

---

### **Access a Running Container**
```bash
docker exec -it -u root <container_id> sh
```
> Used for debugging or inspecting inside a running container.

### **Run New Container in Interactive Mode**
```bash
docker run -it ubuntu
```
- `-it` → Interactive terminal  
> Useful for debugging or testing commands.

---

### **Remove Image**
```bash
docker rmi <image_id_or_name>
```

### **Summary**
- `-d` → Run in background (for servers)  
- `-it` → Run interactively (for debugging or manual work)  
- Always use a **Dockerfile** to build images  
- Use `.dockerignore` to skip unwanted files like `node_modules`  

---

## 🧰 Useful Linux Commands

| Command | Description |
|----------|--------------|
| `pwd` | Show current directory path |
| `whoami` | Display current user |
| `echo $0` | Show current shell program |
| `history` | Display command history |
| `!2` | Run command number 2 from history |

### **File Operations**
```bash
apt update
apt install nano
nano file1.txt
cat file1.txt > file2.txt
cat file1.txt file2.txt > combined.txt
echo "hello world" > file3.txt
head -n 5 file1.txt
tail -n 5 file1.txt
ctrl + l  # clear terminal
apt remove nano
```

### **Directory Operations**
```bash
cd ~
mkdir test
mv test docker
cd docker
touch hello.txt go.txt me.txt
mv hello.txt hello-docker.txt
rm file*
cd ~
rm -r docker
```

---

## 🧹 Docker Cleanup Commands
```bash
docker container rm -f $(docker container ls -aq)
docker image rm -f $(docker image ls -q)
```
- `-a` → Include all containers (running + stopped)

---

## 🌐 Real World Example: Node + Mongo + React (Vidly)

```bash
docker-compose up
```

> This command starts all services defined in the `docker-compose.yml` file.

---

## 🧾 JSON vs YAML

**JSON Example:**
```json
{
  "tags": ["aa", "bb"],
  "author": {
    "first_name": "Sayedul",
    "last_name": "Abrar"
  }
}
```

**YAML Equivalent:**
```yaml
tags:
  - aa
  - bb
author:
  first_name: Sayedul
  last_name: Abrar
```

- JSON → Used for data exchange  
- YAML → Used for configuration (e.g., Docker Compose)  
> YAML is slower because it parses strings before evaluating.

---

## ⚙️ Docker Compose Commands

```bash
docker-compose build --no-cache     # Rebuild without cache
docker-compose build --pull         # Pull latest base images
docker-compose up                   # Start the app
docker compose up --build           # Build + start in one command
docker compose up -d                # Run in background
docker-compose ps                   # Show running services
docker-compose down                 # Stop and remove containers
docker-compose down --rmi all       # Remove containers + images
```

---

## 🌍 Docker Networking

### **Ping Between Containers**
```bash
docker exec -it -u root <frontend_id> sh
ping backend
```
> Docker has an embedded DNS that resolves container names to IPs.

### **View IP**
```bash
ifconfig
```

### **Example `docker-compose.yml`**
```yaml
version: "3.8"

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"

  backend:
    build: ./backend
    ports:
      - "3001:3001"
    environment:
      DB_URL: mongodb://db/vidly

  database:
    image: mongo:4.0-xenial
    ports:
      - "27017:27017"
    volumes:
      - vidly:/data/db

volumes:
  vidly:
```

> This setup allows seamless communication between frontend, backend, and database containers through Docker’s internal network and DNS.

---



---

## 🧱 Docker Volumes and Service Dependencies

### **1. Database Volumes (Data Persistence)**

In the `docker-compose.yml` file:

```yaml
volumes:
  - vidly:/data/db
```

This creates a **named volume** `vidly` that persists data even after container deletion.  
MongoDB stores its data inside `/data/db`, and Docker stores the actual files in `/var/lib/docker/volumes/vidly/_data` in host server.

To inspect where the volume is stored:
```bash
docker volume inspect vidly
```

#### ✅ Alternative: Host Path Bind Mount
You can use a host directory instead of a named volume:
```yaml
volumes:
  - ./mongo_data:/data/db
```
- `./mongo_data` → Path on the host machine  
- `/data/db` → Path inside the container  

| Type | Description | Pros | Cons |
|------|--------------|------|------|
| Named Volume | Managed by Docker | Portable, simple | Harder to inspect |
| Bind Mount | Maps to local folder | Easy to view/edit | OS path dependent |

---

### **2. Service Startup Dependency (Backend waits for DB)**

Without configuration, the **backend** may start before MongoDB is ready.

#### ✅ Basic Dependency with `depends_on`
```yaml
backend:
  build: ./backend
  ports:
    - "3001:3001"
  environment:
    DB_URL: mongodb://db/vidly
  depends_on:
    - database
```
> Ensures the database container starts first — but doesn’t wait for it to be ready.

---

#### 🕓 Recommended: Add a Healthcheck for Real Readiness

Add this under your **database** service:
```yaml
database:
  image: mongo:4.0-xenial
  ports:
    - "27017:27017"
  volumes:
    - vidly:/data/db
  healthcheck:
    test: ["CMD", "mongo", "--eval", "db.adminCommand('ping')"]
    interval: 10s
    timeout: 5s
    retries: 5
```



Here is the updated short note, including the “runs only once vs healthcheck” part:

---

### **Docker Healthcheck Notes**

**1️⃣ CMD (exec form)**

```
test: ["CMD", "mongo", "--eval", "db.adminCommand('ping')"]
```

* Runs the command **directly**, no shell (no `sh -c`).
* Equivalent to Docker internally doing:
  `docker exec <container> mongo --eval "db.adminCommand('ping')"`
* No shell features allowed (no `&&`, pipes, redirects).
* Safe and avoids quoting issues.

**2️⃣ CMD-SHELL (shell form)**

```
test: ["CMD-SHELL", "mongo --eval \"db.adminCommand('ping')\""]
```

* Runs the command through **/bin/sh -c**.
* Supports shell features: `&&`, `|`, redirects, env expansion.

**Normal docker exec**

```bash
docker exec <container> mongo --eval "db.adminCommand('ping')"
```

* Runs **only once**, manually.

**Healthcheck behavior**

* Docker re-runs the test **automatically** based on:

  * `interval` (e.g., every 10s)
  * `timeout`
  * `retries`
* Marks container **healthy/unhealthy** depending on exit codes.

---


Then, make your **backend** wait for it to become healthy:
```yaml
backend:
  build: ./backend
  ports:
    - "3001:3001"
  environment:
    DB_URL: mongodb://db/vidly
  depends_on:
    database:
      condition: service_healthy
```

This ensures the backend only starts **after MongoDB is fully ready**.

---

### **Full Example: Updated docker-compose.yml**

```yaml
version: "3.8"

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"

  backend:
    build: ./backend
    ports:
      - "3001:3001"
    environment:
      DB_URL: mongodb://db/vidly
    depends_on:
      database:
        condition: service_healthy

  database:
    image: mongo:4.0-xenial
    ports:
      - "27017:27017"
    volumes:
      - vidly:/data/db
    healthcheck:
      test: ["CMD", "mongo", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  vidly:
```

---

✅ **Key Takeaways**
- Use **named volumes** for persistence or **bind mounts** for inspection.  
- Add **`depends_on`** for startup order.  
- Use **healthchecks** to ensure dependent services are *ready*, not just *started*.
# 📝 **Short Notes Version**

```
depends_on conditions:

1) service_started → only waits for container to start  
2) service_healthy → waits for healthcheck = healthy  
3) service_completed_successfully → waits for container to finish with exit code 0
```


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


## Practical Example: Running NGINX with Bind Mounts

To illustrate bind mounts in action, letâ€™s consider a scenario where weâ€™re running an NGINX web server inside a Docker container. Our goal is to:
- Provide NGINX with a custom configuration file stored on the host.
- Allow NGINX to write access logs to a file on the host.


![](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/mapping.drawio.svg)


Using bind mounts, we can achieve this seamlessly. Here’s how to set it up, step by step, using Docker Compose instead of direct `docker run` commands. We'll provide a `docker-compose.yaml` file to define the NGINX service with bind mounts. Since no custom image build is required (we're using `nginx:latest` directly), a minimal `Dockerfile` is included for completeness, but it's optional and not used in the Compose setup—Compose will pull the official image.

### Step 1: Preparing the Host Files

First, we need to create the files that NGINX will use inside the container. We'll place them in the current working directory for easy relative paths in Compose.

1. **Create an Empty Log File**  
   On the host, we’ll create an empty file to store NGINX’s access logs:
   ```bash
   touch example.log
   ```
   This command generates `example.log` in your current directory. NGINX will later write its access logs to this file via a bind mount.

2. **Create a Custom NGINX Configuration File**  
   Next, we’ll define a simple NGINX configuration:
   ```bash
   cat > example.conf <<EOF
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
   This creates `example.conf` in the current directory with the following settings:
   - The server listens on port 80.
   - It serves files from `/usr/share/nginx/html` (NGINX’s default content directory).
   - Access logs are written to `/var/log/nginx/custom.host.access.log`.

These files will serve as the source paths for our bind mounts in the Compose file.

### Optional: Minimal Dockerfile (Not Required for This Setup)
If you wanted to build a custom NGINX image (e.g., for baking in additional configurations or extensions in the future), here's a basic `Dockerfile`. However, for this bind mount demo, we don't need to build an image—Docker Compose will use `nginx:latest` directly. Save this as `Dockerfile` if you choose to use it (and update the Compose file's `build` section accordingly).

```dockerfile
# Use the official NGINX image as the base
FROM nginx:latest

# No additional customizations needed for bind mounts, but you could add things like:
# COPY custom-files /some/path (if not using mounts)

# Expose the default port
EXPOSE 80

# Default command (inherited from base image)
CMD ["nginx", "-g", "daemon off;"]
```

### Step 2: Creating the Docker Compose File

Create a file named `docker-compose.yaml` in the same directory as your `example.conf` and `example.log`. Here's the content:

```yaml
version: '3.8'  # Compatible Docker Compose version

services:
  diaweb:  # Service name (container will be named based on this)
    image: nginx:latest  # Use the official NGINX image (or build: . if using the optional Dockerfile)
    container_name: diaweb  # Explicit container name
    ports:
      - "8000:80"  # Map host port 8000 to container port 80
    volumes:
      - ./example.conf:/etc/nginx/conf.d/default.conf  # Bind mount for config (overriding default)
      - ./example.log:/var/log/nginx/custom.host.access.log  # Bind mount for logs
    restart: unless-stopped  # Optional: Add a restart policy for reliability (from previous discussions)

# If using the optional Dockerfile, uncomment this and comment out 'image':
#    build: .
```

Let’s break this down:
- `image: nginx:latest`: Pulls the latest NGINX image from Docker Hub.
- `container_name: diaweb`: Names the container `diaweb`.
- `ports: - "8000:80"`: Maps port 8000 on the host to port 80 in the container, making the web server accessible at `http://localhost:8000`.
- `volumes:`: Defines the bind mounts.
  - `./example.conf:/etc/nginx/conf.d/default.conf`: Binds `example.conf` from the host (current dir) to `/etc/nginx/conf.d/default.conf` in the container, overriding NGINX’s default configuration.
  - `./example.log:/var/log/nginx/custom.host.access.log`: Binds `example.log` to `/var/log/nginx/custom.host.access.log`, allowing NGINX to write logs to it.
- `restart: unless-stopped`: (Optional) Ensures the container restarts automatically unless manually stopped (as discussed in prior restart policy examples).

### Step 3: Launching the NGINX Container with Docker Compose

With the files ready, start the container using Compose:

```bash
docker-compose up -d
```

- `-d`: Runs in detached mode (background).

Once executed, the container starts, and NGINX begins serving content based on our custom configuration.

### Step 4: Verifying the Setup

Let’s confirm that everything is working as expected.

1. **Access the Web Server**  
   Test the NGINX server by sending a request:
   ```bash
   curl http://localhost:8000
   ```

   You should see NGINX’s default welcome page HTML, indicating the server is running correctly.

   You can also check the Nginx UI at the following URL:

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-4.png)

   Click on the URL to see the Nginx UI.

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-3.png)

2. **Check the Logs**  
   Inspect the log file on the host:
   ```bash
   cat example.log
   ```

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-5.png)

   You’ll see an entry corresponding to the `curl` request, confirming that NGINX is writing logs to the host file via the bind mount.

### Step 5: Securing the Configuration with Read-Only Mounts

For added security, we can configure the bind mount for the configuration file to be read-only, preventing the container from modifying it.

1. **Stop and Remove the Existing Container**  
   Clean up the previous setup:
   ```bash
   docker-compose down
   ```

2. **Update the Docker Compose File for Read-Only**  
   Edit `docker-compose.yaml` to add `:ro` (read-only) to the config volume:
   ```yaml
   version: '3.8'

   services:
     diaweb:
       image: nginx:latest
       container_name: diaweb
       ports:
         - "8000:80"
       volumes:
         - ./example.conf:/etc/nginx/conf.d/default.conf:ro  # Now read-only
         - ./example.log:/var/log/nginx/custom.host.access.log
       restart: unless-stopped
   ```

3. **Relaunch with Docker Compose**  
   Start it again:
   ```bash
   docker-compose up -d
   ```

   The `:ro` flag ensures that `/etc/nginx/conf.d/default.conf` inside the container cannot be altered.

   ![alt text](https://raw.githubusercontent.com/poridhiEng/lab-asset/6e2329b5d484fd85fbd9f5b4e51aa4259ed9104f/Docker%20Labs/Lab%2012/images/image-6.png)

### Step 6: Testing the Read-Only Restriction

Let’s verify that the read-only setting works by attempting to modify the configuration file inside the container:
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




# Docker tmpfs mounts – quick cheat sheet

### Why use tmpfs?

- In-memory filesystem (RAM, super fast)

- Never touches host disk → no persistence, no logs, no secrets on disk

- Prevents container from filling your SSD/HDD with temp files

- Great for `/tmp`, `/run`, secrets, build caches

### Basic syntax (modern Docker, 2025+)

bash

--tmpfs /path[:options]



### Common one-liners

```bash

# Simple /tmp in RAM (most common)

--tmpfs /tmp

# Limit size (highly recommended in production)

--tmpfs /tmp:size=64m

--tmpfs /tmp:size=256m

--tmpfs /tmp:size=10%        # 10 % of host RAM

# Full control (rarely needed)
--tmpfs /tmp:size=100m,uid=1000,gid=1000,mode=1777
```


### How to find correct uid/gid for any image

# Docker tmpfs – final ultra-short cheat sheet

Check UID/GID + /tmp mode in ONE command:
```bash
docker run --rm your-image sh -c "id; stat -c '%u %g %a %A' /tmp"



### Real-world examples



### Mount multiple tmpfs

```bash

--tmpfs /tmp:size=128m \

--tmpfs /run:size=32m \

--tmpfs /var/run/lock
```


### Docker Compose equivalent

```yaml

services:

  app:

    image: node:20-alpine

    tmpfs:

      - /tmp:size=256m,uid=1000,gid=1000

      - /run:size=50m
```


### Golden rule

Always add a size limit in production → prevents a buggy process from eating all RAM.

Copy-paste ready!



```bash

docker run --rm --tmpfs /tmp:size=256m,uid=$(docker run --rm your-image id -u),gid=$(docker run --rm your-image id -g) your-image ...
```


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

Next, run a `Cassandra container` and mount the previously created volume to the container.

```bash
docker run -d \
    --volume cass-shared:/var/lib/cassandra/data \
    --name cass1 \
    cassandra:2.2
```
![](https://raw.githubusercontent.com/poridhiEng/lab-asset/488790ccc4e286fab4b9defc335d0193889d4c8b/Docker%20Labs/Lab%2014/images/2.png)

**Explanation:**

- **docker run -d:** Runs the container in detached mode.
- **--volume cass-shared:/var/lib/cassandra/data:** Mounts the cass-shared volume to /var/lib/cassandra/data inside the container.
- **--name cass1:** Names the container cass1.
- **cassandra:2.2:** Uses the Cassandra image version 2.2 from Docker Hub.

## Step 3: Connect to the Cassandra Container

Use the Cassandra client tool `(CQLSH)` to connect to the running Cassandra server.

```bash
docker run -it --rm \
    --link cass1:cass \
    cassandra:2.2 \
    cqlsh cass
```

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


---

# 🐳 **Docker Volumes vs Bind Mounts — When to Use Which?**

## ✅ **Use a *Docker Volume* when…**

### **1. You want Docker to manage the data.**

Docker handles the storage location, permissions, and cleanup.

### **2. Data belongs to the container/application, not the host.**

Examples:

* Database storage (PostgreSQL, MySQL, MongoDB)
* Application-generated files
* Service state data

### **3. You want portability and easy backups.**

Volumes work consistently regardless of host OS or filesystem structure.

### **4. You need better performance.**

Volumes are usually faster than bind mounts, especially on macOS/Windows.

### **5. You want to share data between containers.**

Volumes make this safe and easy.

### **6. You want isolation from the host filesystem.**

Useful when:

* You don’t trust the container
* You want predictable, controlled paths
* You want to avoid accidental deletion of host files

---

# 🧷 **Use a *Bind Mount* when…**

### **1. You need live syncing with host files.**

Common for development.
Examples:

* Mount your project source code into a container
* Edit files locally and see results immediately inside the container

### **2. You need the container to access existing host files.**

Examples:

* Config files
* Log files
* SSL certificates from the host
* A specific directory you already maintain

### **3. You need full control over the host directory.**

Bind mounts use **exactly the path you specify**, allowing:

* Custom permissions
* Custom directory structure

### **4. You need to work with tools/editors on your host.**

For dev environments:

```yaml
volumes:
  - ./src:/app/src  # bind mount
```

This keeps your live code outside Docker.



# 🧭 Rule of Thumb

* **Production** → Use **volumes**.
* **Local development** → Use **bind mounts**.
* **Storing app data** → Volumes.
* **Editing source code** → Bind mounts.
* **Sharing data between containers** → Volumes.

---

# 📦 Real Examples

### **Use Docker Volume (production DB):**

```yaml
services:
  db:
    image: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

### **Use Bind Mount (live code editing):**

```yaml
services:
  app:
    image: node
    volumes:
      - ./:/usr/src/app
```






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



## Repository-Specific Images

Let's pull nginx images from the repository:

```bash
docker pull nginx
```

To list images from a `specific repository`, we can use the `reference` filter:

```bash
docker images --filter reference="nginx"
```

Expected Outout:

```bash
root@e2379709071bc168:~/code# docker images --filter reference="nginx"
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
nginx        latest    53a18edff809   8 weeks ago   192MB
root@e2379709071bc168:~/code# 
```

## Images Before a Specific Image

Let's pull some docker images:

```bash
docker pull alpine
docker pull busybox
```

If we use the following command we can see all the images with their created time:

```bash
docker images
```

Expected Outout:

```
root@e2379709071bc168:~/code# docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
alpine       latest    aded1e1a5b37   7 weeks ago    7.83MB
nginx        latest    53a18edff809   8 weeks ago    192MB
busybox      latest    ff7a7936e930   6 months ago   4.28MB
root@e2379709071bc168:~/code# 
```

To list images created before a specific image use `before`:

```sh
docker images --filter before=alpine 
```

Expected Output:
```
root@e2379709071bc168:~/code# docker images --filter before=alpine
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        latest    53a18edff809   8 weeks ago    192MB
busybox      latest    ff7a7936e930   6 months ago   4.28MB
```


## Images Since a Specific Image

To list images created after a specific image use `since`:

```bash
docker images --filter since=busybox
```


Expected Output:

```sh
root@e2379709071bc168:~/code# docker images --filter since=busybox
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
alpine       latest    aded1e1a5b37   7 weeks ago   7.83MB
nginx        latest    53a18edff809   8 weeks ago   192MB
```

## Images with Specific Labels





This filtering is particularly useful in `CI/CD pipelines` where there is a need to deploy, test, or manage specific versions of Docker images based on labels.

Let's assume we have several Docker images on our system, and some of these images have been tagged with a specific label, `com.example.version=1.0`.


### Adding Labels to Images

If we want to create a Docker image with a specific label, we can do so during the build process. Here's an example Dockerfile that includes a label:

```Dockerfile
# Example Dockerfile
FROM alpine:latest
LABEL com.example.version="1.0"
COPY . /app
CMD ["sh", "/app/start.sh"]
```

To build this image and tag it as `myapp:v1.0`, we would use:

```sh
docker build -t myapp:v1.0 .
```

After building, this image will have the label `com.example.version=1.0`, and we can verify this by using the `filter` command.


To filter and list only the images that have this label, we would use the following command:

```sh
docker images --filter label=com.example.version=1.0
```

Expected output:
```sh
root@e2379709071bc168:~/code# docker images --filter label=com.example.version=1.0
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
myapp        v1.0      ff509c997c6d   19 seconds ago   7.83MB
root@e2379709071bc168:~/code# 
```

In this example the image `myapp` with the tag `v1.0` has the label `com.example.version=1.0`.



## Images by Reference

To list images with the `latest` tag:

```bash
docker images --filter reference="*:latest"
```

Expected output:

```sh
root@e2379709071bc168:~/code# docker images --filter reference="*:latest"
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
alpine       latest    aded1e1a5b37   7 weeks ago    7.83MB
nginx        latest    53a18edff809   8 weeks ago    192MB
busybox      latest    ff7a7936e930   6 months ago   4.28MB
root@e2379709071bc168:~/code# 
```

## Formatting Output

The `--format` flag allows us to customize the output using `Go templates`. For example, to display only the sizes of the images:

```sh
root@e2379709071bc168:~/code# docker images --format "{{.Size}}"
7.83MB
7.83MB
192MB
4.28MB
root@e2379709071bc168:~/code# 
```

We can also customize the output of `docker images` command output to display only the repository, tag, and size of each image:

```sh
root@e2379709071bc168:~/code# docker images --format "{{.Repository}}: {{.Tag}}: {{.Size}}"
myapp: v1.0: 7.83MB
alpine: latest: 7.83MB
nginx: latest: 192MB
busybox: latest: 4.28MB
root@e2379709071bc168:~/code# 
```


## Basic Usage

In its most basic form, `docker search` looks for repositories that contain a specified string in their `â€œNAMEâ€` field. For example, the following command searches for repositories that include the string `â€œnigelpoultonâ€`:

```bash
docker search nigelpoulto
```

The â€œNAMEâ€ field refers to the repository name, which includes the Docker ID or organization name for unofficial repositories. This will display all repositories created by or associated with `Nigel Poulton`.

## Searching for Specific Terms

We can also search for repositories that include specific keywords. For example, to search for repositories with "alpine" in the name, you would use:

```sh
docker search alpine
```

Here, we can see both official and unofficial repositories:

```bash
root@bccc43e8b428c7bd:~/code# docker search alpine
NAME                DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
alpine              A minimal Docker image based on Alpine Linuxâ€¦   11256     [OK]       
alpine/git          A  simple git container running in alpine liâ€¦   240                  [OK]
alpine/socat        Run socat command in alpine container           108                  [OK]
alpine/helm         Auto-trigger docker build for kubernetes helâ€¦   69                   
alpine/curl                                                         9                    
alpine/k8s          Kubernetes toolbox for EKS (kubectl, helm, iâ€¦   59                   
alpine/httpie       Auto-trigger docker build for `httpie` when â€¦   21                   [OK]
alpine/bombardier   Auto-trigger docker build for bombardier wheâ€¦   27                   
alpine/terragrunt   Auto-trigger docker build for terragrunt wheâ€¦   18                   
alpine/openssl      openssl                                         4                    
alpine/flake8       Auto-trigger docker build for fake8 via ci câ€¦   2                    
alpine/ansible      run ansible and ansible-playbook in docker      25                   
alpine/jmeter       run jmeter in Docker                            9                    
alpine/semver       Docker tool for semantic versioning             5                    [OK]
alpine/gcloud       Auto-trigger docker build for gcloud (googleâ€¦   0                    
alpine/bundle       This repository has been archived by the ownâ€¦   1                    
alpine/mysql        mysql client                                    4                    
alpine/xml          several xml tools to work on xml file as jq â€¦   1                    
alpine/cfn-nag      Auto-trigger docker build for cfn-nag when nâ€¦   0                    
alpine/psql         psql â€” The PostgreSQL Command-Line Client       1                    
alpine/dfimage      reverse Docker images into Dockerfiles          70                   
alpine/mongosh      mongosh - MongoDB Command Line Database Tools   2                    
alpine/java         Repo containing the build scripts to produceâ€¦   2                    
alpine/cfn-lint                                                     0                    
alpine/doctl        DigitalOcean command line with kubernetes anâ€¦   0                    
root@bccc43e8b428c7bd:~/code# 
```

## Filtering Official Repositories

To filter the search results and display only official repositories, you can use the `--filter` option with the `is-official` parameter:

```bash
docker search alpine --filter "is-official=true"
```

Expected output:

```sh
root@4484998ba19e9f2d:~/code# docker search alpine --filter "is-official=true"
NAME      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
alpine    A minimal Docker image based on Alpine Linuxâ€¦   11256     [OK]       
root@4484998ba19e9f2d:~/code# 
```

### Example Scenario

Suppose, we are managing a production environment and need to ensure that only trusted and verified images are used. We can filter for official images to ensure compliance with security policies:

```sh
docker search alpine --filter "is-official=true"
```

This command will help us to find only the official Alpine images, which are more likely to be secure and maintained.

## Limiting Results

By default, `docker search` will return up to `25` results. If we need more, we can use the `--limit` flag to increase this number, up to a maximum of `100` results:

```sh
docker search alpine --limit 50
```

### Example Scenario

Suppose you are conducting a comprehensive review of available Alpine images for a project and need more than the default 25 results, increasing the limit can provide a broader view of available options:

```sh
docker search alpine --limit 50
```

## Advanced Filtering

In addition to filtering for official images, Docker search supports other filters, such as the number of `stars` or whether the image is `automated`. For example, to find automated images with â€œalpineâ€ in the name, you could use:

```sh
docker search alpine --filter "is-automated=true"
```

The "is-automated" filter is deprecated by the way, and searching for "is-automated=true" will not yield any results in future but for now is ok.

### Example Scenario

If you prefer to use automated builds because they often include continuous integration and delivery (CI/CD) practices, you can filter for these types of images:

```sh
$ docker search alpine --filter "is-automated=true"
```

This helps you identify images that are automatically built and potentially more reliable for use in your workflows.