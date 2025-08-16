package modules 

import (
	"context"

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

func ConfigureFirebase(ctx context.Context, credFile string) (*messaging.Client, error) {
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
