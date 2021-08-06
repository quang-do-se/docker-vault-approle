package spring.vault;


import java.net.URI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.vault.authentication.AppRoleAuthentication;
import org.springframework.vault.authentication.AppRoleAuthenticationOptions;
import org.springframework.vault.authentication.AppRoleAuthenticationOptions.RoleId;
import org.springframework.vault.authentication.AppRoleAuthenticationOptions.SecretId;
import org.springframework.vault.authentication.ClientAuthentication;
import org.springframework.vault.client.VaultEndpoint;
import org.springframework.vault.config.AbstractVaultConfiguration;

@Configuration
public class VaultConfiguration extends AbstractVaultConfiguration {
    @Value("${vault.uri:http://127.0.0.1:8200}")
    URI vaultUri;

    @Value("${vault.app-role.role-id}")
    String roleId;

    @Value("${vault.app-role.secret-id}")
    String secretId;

    @Override
    public VaultEndpoint vaultEndpoint() {
        return VaultEndpoint.from(vaultUri);
    }

    @Override
    public ClientAuthentication clientAuthentication() {
        AppRoleAuthenticationOptions options = AppRoleAuthenticationOptions.builder()
                                                       .roleId(RoleId.provided(roleId))
                                                       .secretId(SecretId.provided(secretId))
                                                       .build();

        return new AppRoleAuthentication(options, restOperations());
    }
}
