package modules

import (
	"encoding/json"
	"errors"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type Loan struct {
	ID          string `json:"id"`
	ImageURL    string `json:"imageUrl"`
	ReturnDate  string `json:"returnDate"`
	Reason      string `json:"reason"`
	IsActive    bool   `json:"isActive"`
	Item        int    `json:"item"`
	Applicant   string `json:"applicant"`
	Dependent   string `json:"dependent"`
	Responsible string `json:"responsible"`
	DeviceToken string `json:"deviceToken"`
	CreatedAt   string `json:"createdAt"`
}

type LoansResponse struct {
	Success bool   `json:"success"`
	Count   int    `json:"count"`
	Data    []Loan `json:"data"`
	Message string `json:"message"`
}

func FetchLoans() ([]Loan, error) {
	// Carrega variáveis do .env
	_ = godotenv.Load()
	url := os.Getenv("API_URL")
	apiKey := os.Getenv("API_KEY")
	if url == "" {
		return nil, errors.New("API_URL not set in environment")
	}
	if apiKey == "" {
		return nil, errors.New("API_KEY not set in environment")
	}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("x-api-key", apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("failed to fetch loans: status " + resp.Status)
	}

	var loansResp LoansResponse
	if err := json.NewDecoder(resp.Body).Decode(&loansResp); err != nil {
		return nil, err
	}

	return loansResp.Data, nil
}
