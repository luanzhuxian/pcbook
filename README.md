# PC Book - gRPC 微服务项目

PC Book 是一个基于 gRPC 的微服务项目，实现了笔记本电脑管理系统。项目包含认证服务、笔记本管理服务，支持 TLS 加密通信，并通过 Nginx 实现负载均衡。

## 项目特性

- **gRPC 服务**：实现了完整的 gRPC 服务端和客户端
- **REST API**：通过 gRPC-Gateway 支持 RESTful API
- **双向 TLS**：支持 mTLS 认证，确保通信安全
- **微服务架构**：服务拆分为认证服务和业务服务
- **负载均衡**：使用 Nginx 作为反向代理和负载均衡器
- **API 文档**：自动生成 OpenAPI v2 (Swagger) 文档
- **容器化部署**：支持 Docker 和 Docker Compose 部署

## 目录结构

```
pcbook/
├── buf.gen.yaml          # Buf 代码生成配置
├── buf.yaml              # Buf 模块配置
├── cert/                 # TLS 证书目录
│   └── gen.sh           # 证书生成脚本
├── cmd/                  # 应用程序入口
│   ├── client/          # gRPC 客户端
│   └── server/          # gRPC 服务端
├── build/               # 构建相关文件
│   └── Dockerfile       # 服务器 Docker 镜像
├── nginx/               # Nginx 配置
│   ├── Dockerfile       # Nginx Docker 镜像
│   └── config/
│       └── nginx.conf   # Nginx 配置文件
├── docker-compose.yml   # Docker Compose 配置
├── openapiv2/           # 生成的 Swagger 文档
├── pb/                  # 生成的 Protocol Buffer 代码
├── proto/               # Protocol Buffer 定义文件
├── service/             # 业务逻辑实现
└── swagger-ui.html      # Swagger UI 页面
```

## 快速开始

### 前置要求

- Go 1.15+
- Protocol Buffers 编译器 (protoc)
- Buf CLI 工具
- Docker 和 Docker Compose（用于容器化部署）
- Make 工具

### 安装依赖

1. 安装 Protocol Buffer 编译器插件：

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
```

2. 安装 Buf CLI：

```bash
# macOS
brew install bufbuild/buf/buf

# 或者使用 Go install
go install github.com/bufbuild/buf/cmd/buf@latest
```

## 使用说明

### 1. 生成代码

#### 使用 Make（传统方式）

```bash
make gen
```

#### 使用 Buf（推荐）

```bash
buf generate
```

这将生成：

- Protocol Buffer Go 代码
- gRPC 服务代码
- gRPC-Gateway 代码
- OpenAPI v2 (Swagger) 文档

### 2. 生成 TLS 证书

```bash
make cert
```

这将在 `cert/` 目录下生成：

- CA 证书
- 服务器证书和密钥
- 客户端证书和密钥

### 3. 运行服务

#### 单机模式

**启动 gRPC 服务器（默认端口 8080）：**

```bash
make server
```

**启动 REST API 网关：**

```bash
make rest
```

#### 多服务器模式（用于负载均衡测试）

**启动服务器 1（端口 50051）：**

```bash
make server1     # 不带 TLS
make server1-tls # 带 TLS
```

**启动服务器 2（端口 50052）：**

```bash
make server2     # 不带 TLS
make server2-tls # 带 TLS
```

### 4. 运行客户端

**连接到服务器：**

```bash
make client     # 不带 TLS
make client-tls # 带 TLS
```

### 5. 运行测试

```bash
make test
```

### 6. 清理生成的代码

```bash
make clean
```

## Docker 部署

### 使用 Docker Compose 启动微服务

```bash
# 启动所有服务（2个 gRPC 服务器 + Nginx）
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

Docker Compose 将启动：

- **server1**: 认证服务（端口 50051，带 TLS）
- **server2**: 笔记本服务（端口 50052，带 TLS）
- **nginxservice**: Nginx 反向代理（端口 8080，带 TLS）

### Nginx 负载均衡配置

Nginx 配置了基于路径的路由：

- `/techschool_pcbook.AuthService/*` → server1:50051
- `/techschool_pcbook.LaptopService/*` → server2:50052

支持的特性：

- HTTP/2 和 gRPC 代理
- 双向 TLS 认证（mTLS）
- 自动故障转移

## API 文档（Swagger）

### 查看 Swagger 文档

1. **启动本地 HTTP 服务器：**

```bash
python3 -m http.server 8080
```

2. **在浏览器中访问：**

```
http://localhost:8080/swagger-ui.html
```

3. **可用的 API 文档：**
   - Laptop Service - 笔记本管理服务
   - Auth Service - 认证服务

### API 端点

#### gRPC 端点

- 创建笔记本：`CreateLaptop`
- 搜索笔记本：`SearchLaptop`（流式响应）
- 上传图片：`UploadImage`（流式请求）
- 评分笔记本：`RateLaptop`（双向流）
- 用户登录：`Login`

#### REST API 端点（通过 gRPC-Gateway）

- POST `/v1/auth/login` - 用户登录
- POST `/v1/laptop/create` - 创建笔记本
- GET `/v1/laptop/search` - 搜索笔记本
- POST `/v1/laptop/upload` - 上传图片
- POST `/v1/laptop/rate` - 评分笔记本

## 开发指南

### 添加新的 gRPC 服务

1. 在 `proto/` 目录下创建新的 `.proto` 文件
2. 添加必要的 gRPC-Gateway 注解
3. 运行 `buf generate` 生成代码
4. 在 `service/` 目录下实现服务逻辑
5. 更新 `cmd/server/main.go` 注册新服务

### 更新 API 文档

当修改 proto 文件后，运行以下命令更新 Swagger 文档：

```bash
buf generate
```

文档将自动生成到 `openapiv2/` 目录。

## 测试示例

### 使用 gRPC 客户端测试

```bash
# 运行客户端进行测试
go run cmd/client/main.go -address localhost:8080
```

### 使用 cURL 测试 REST API

```bash
# 登录
curl -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "secret"}'

# 创建笔记本
curl -X POST http://localhost:8081/v1/laptop/create \
  -H "Content-Type: application/json" \
  -d '{
    "laptop": {
      "brand": "Apple",
      "name": "MacBook Pro 16",
      "cpu": {...},
      "memory": {...}
    }
  }'
```

## 故障排除

### 常见问题

1. **protoc 命令找不到**

   - 确保已安装 protoc 和相关插件
   - 检查 `$GOPATH/bin` 是否在 PATH 中

2. **证书错误**

   - 运行 `make cert` 重新生成证书
   - 确保证书路径正确

3. **端口被占用**
   - 检查端口占用：`lsof -i :8080`
   - 修改 Makefile 中的端口配置
