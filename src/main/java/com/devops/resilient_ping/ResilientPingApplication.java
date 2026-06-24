package com.devops.resilient_ping;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
import io.micrometer.prometheus.PrometheusConfig;
import io.micrometer.prometheus.PrometheusMeterRegistry;
import io.micrometer.core.instrument.Counter;

@SpringBootApplication
@EnableScheduling // 1. Tells Spring to look for background loop tasks
public class ResilientPingApplication {

    public static void main(String[] args) {
        SpringApplication.run(ResilientPingApplication.class, args);
    }

    // 2. Register the Prometheus Registry as a Spring Bean so the whole app can share it
    @Bean
    public PrometheusMeterRegistry prometheusMeterRegistry() {
        return new PrometheusMeterRegistry(PrometheusConfig.DEFAULT);
    }
}

@Component
class PingBackgroundWorker {

    private final Counter successCounter;
    private final Counter failedCounter;

    // 3. Dependency Injection: Spring automatically passes the shared registry here
    public PingBackgroundWorker(PrometheusMeterRegistry registry) {
        this.successCounter = Counter.builder("ping_requests_total")
                .description("The total number of ping requests sent")
                .tag("status", "success")
                .register(registry);

        this.failedCounter = Counter.builder("ping_requests_total")
                .description("The total number of ping requests sent")
                .tag("status", "failed")
                .register(registry);
    }

    // 4. This replaces 'while(true)'. Spring runs this task safely on a separate thread every 5000ms
    @Scheduled(fixedDelay = 5000)
    public void executePingLoop() {
        try {
            boolean success = sendPing("8.8.8.8");
            if (success) {
                successCounter.increment();
            } else {
                failedCounter.increment();
            }
        } catch (Exception e) {
            failedCounter.increment();
        }
    }

    private boolean sendPing(String ip) {
        // Your existing ping logic goes here
        return true;
    }
}

@RestController
class PingController {

    private final PrometheusMeterRegistry registry;

    public PingController(PrometheusMeterRegistry registry) {
        this.registry = registry;
    }

    @GetMapping("/ping")
    public Map<String, String> ping() {
        return Map.of(
            "status", "UP",
            "message", "Infrastructure target responding normally"
        );
    }

    // 5. Clean REST endpoint mapping directly to your shared Prometheus instance
    @GetMapping("/metrics")
    public String metrics() {
        return registry.scrape();
    }
}
