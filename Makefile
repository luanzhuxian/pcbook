gen:
	protoc --go_out=pb --go-grpc_out=pb --proto_path=proto proto/*.proto

clean:
	rm -rf ./grpc/pb/*

run:
	go run main.go

test:
	go test -cover -race ./...