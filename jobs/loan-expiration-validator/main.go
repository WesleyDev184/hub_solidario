package main

import (
	"context"
	"log"

	"firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

func main() {
	// Inicialize o SDK Admin do Firebase
	opt := option.WithCredentialsFile("./hubapp.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("erro ao inicializar o app: %v\n", err)
	}

	// Obtenha um cliente para o Firebase Cloud Messaging
	ctx := context.Background()
	client, err := app.Messaging(ctx)
	if err != nil {
		log.Fatalf("erro ao obter o cliente de Messaging: %v\n", err)
	}

	// O token de registro do dispositivo para o qual você deseja enviar a notificação.
	// Este token é gerado pelo SDK do Firebase no seu aplicativo cliente.
	// Você precisará obtê-lo do seu aplicativo cliente e enviá-lo para o seu servidor.
	registrationToken := "dBzbyoOZRrye-_jn3APqSd:APA91bEv_nSGAv6yBA-MgyoZCi52DqbYh5t4K-pb13t3r2iggOroup1pKqoR3js5kWBp55zmmo8cl95CP1y02GeZqG0l_a02MWsy7UCZBz8-jXCUR6et7ec"

	// Crie a mensagem a ser enviada
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: "Olá do Go!",
			Body:  "Esta é uma notificação enviada do nosso servidor Go!",
		},
		Token: registrationToken,
	}

	// Envie a mensagem
	response, err := client.Send(ctx, message)
	if err != nil {
		log.Fatalln(err)
	}
	// A resposta contém o ID da mensagem
	log.Println("Notificação enviada com sucesso:", response)
}