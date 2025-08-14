package main

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

type AppNotification struct {
	Title string
	Body  string
	Token string
	Data  map[string]string
}

func SendNotification(ctx context.Context, client *messaging.Client, notif AppNotification) (string, error) {
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: notif.Title,
			Body:  notif.Body,
		},
		Token: notif.Token,
		Data:  notif.Data,
	}
	return client.Send(ctx, message)
}

func configureFirebase(ctx context.Context, credFile string) (*messaging.Client, error) {
	opt := option.WithCredentialsFile(credFile)
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, err
	}
	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, err
	}
	return client, nil
}

func main() {
	ctx := context.Background()
	client, err := configureFirebase(ctx, "./hubapp.json")
	if err != nil {
		log.Fatalf("erro ao configurar o Firebase: %v\n", err)
	}

	notif := AppNotification{
		Title: "Olá do Go!",
		Body:  "Esta é uma notificação enviada do nosso servidor Go!",
		Token: "dBzbyoOZRrye-_jn3APqSd:APA91bEv_nSGAv6yBA-MgyoZCi52DqbYh5t4K-pb13t3r2iggOroup1pKqoR3js5kWBp55zmmo8cl95CP1y02GeZqG0l_a02MWsy7UCZBz8-jXCUR6et7ec",
		Data:  map[string]string{"route": "/ptd/loans"},
	}

	response, err := SendNotification(ctx, client, notif)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("Notificação enviada com sucesso:", response)
}
