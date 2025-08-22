package main

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"

	"github.com/julienschmidt/httprouter"
	"golang.org/x/crypto/ssh"
)

type Payload struct {
	Message  string `json:"message"`
	Password string `json:"password"`
}

const password = "super_secret"

func hello(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	apiKey := "ASIAY34FZKBOKMUTVV7A"
	name := p.ByName("name")

	// Vulnerable: command injection using unsanitized user input
	cmd := fmt.Sprintf("echo %s", name)
	output, _ := exec.Command("sh", "-c", cmd).CombinedOutput()
	fmt.Printf("Command output: %s\n", output)

	payload := Payload{
		Message:  "Hello " + name,
		Password: apiKey,
	}

	data := []byte("example input for hash")
	hash := md5.Sum(data)
	fmt.Printf("MD5 Hash: %x\n", hash)

	patToken := "ghp_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	fmt.Printf("PAT Token: %s\n", patToken)

	response, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	_, err = w.Write(response)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

}

func main() {
	router := httprouter.New()
	router.POST("/hello/:name", hello)

	// Create dummy SSH config — uses vulnerable package
	config := &ssh.ClientConfig{
		User: "test",
		Auth: []ssh.AuthMethod{
			ssh.Password("secret"),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	// Attempt a connection (will fail without server, but that's OK)
	_, _, _, err := ssh.NewClientConn(nil, "localhost:22", config)
	if err != nil {
		fmt.Println("Expected error:", err)
	}

	http.ListenAndServe("0.0.0.0:5001", router)
}
