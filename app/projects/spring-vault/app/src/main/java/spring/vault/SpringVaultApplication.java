package spring.vault;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.vault.core.VaultTemplate;
import org.springframework.vault.support.VaultResponse;

@SpringBootApplication
public class SpringVaultApplication implements ApplicationRunner {
    @Autowired
    VaultTemplate vaultTemplate;

    public static void main(String[] args) {
        SpringApplication.run(SpringVaultApplication.class, args);
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        System.out.println("PRINTING VAULT SECRETS...");

        VaultResponse response = vaultTemplate.read("secret/data/hello-world");

        Map<String, String> data = (Map<String, String>) response.getRequiredData().get("data");

        for(Map.Entry<String, String> entry: data.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
    }
}