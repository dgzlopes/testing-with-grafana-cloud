import { QuickPizzaAPIClient } from "../_lib/http_client.ts";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL || "https://quickpizza.grafana.com";

export default function () {
    const client = new QuickPizzaAPIClient({
        baseUrl: BASE_URL,
        commonRequestParameters: {
            headers: {
                Authorization: `token abcdef0123456789`,
            },
        },
    });

    const { response, data } = client.getPizzaRecommendation({
        mustBeVegetarian: true,
        maxCaloriesPerSlice: 500,
    });

    check(response, {
        "status is 200": (res) => res.status === 200,
        "response has pizza": () => data?.pizza !== undefined,
        "is vegetarian": () => data?.vegetarian === true,
        "within calorie limit": () => (data?.calories ?? 0) <= 500,
    });
    
    sleep(1);
}
