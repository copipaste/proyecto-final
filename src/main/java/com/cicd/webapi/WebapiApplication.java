package com.cicd.webapi;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
public class WebapiApplication {

	public static void main(String[] args) {
		SpringApplication.run(WebapiApplication.class, args);
	}

}

@RestController
class HelloController {
    @GetMapping("/")
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello CI/CD World!");
        response.put("status", "running");
        response.put("docs", "/api/instance, /api/info, /api/uptime, /health, /date, /api/calc/add, /api/calc/multiply");
        return response;
    }
}

@RestController
class HealthController {
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "Server Healthy!");
        return response;
    }
}

@RestController
class DateController {
    @GetMapping("/date")
    public Map<String, String> date() {
        Map<String, String> response = new HashMap<>();
        response.put("date", java.time.LocalDate.now().toString());
        return response;
    }
}

@RestController
class InstanceController {

    @Value("${INSTANCE_NAME:BLUE}")
    private String instanceName;

    @Value("${server.port:8080}")
    private String port;

    @Value("${APP_VERSION:1.0.0}")
    private String version;

    @GetMapping("/api/instance")
    public Map<String, String> getInstance() {
        Map<String, String> response = new HashMap<>();
        response.put("instance", instanceName);
        response.put("port", port);
        response.put("version", version);
        response.put("status", "ACTIVE");
        return response;
    }
}

@RestController
class InfoController {

    @GetMapping("/api/info")
    public Map<String, String> getInfo() {
        Map<String, String> response = new HashMap<>();
        response.put("application", "Diplomado CI/CD WebAPI");
        response.put("java_version", System.getProperty("java.version"));
        response.put("os_name", System.getProperty("os.name"));
        return response;
    }
}

@RestController
class UptimeController {

    private static final long START_TIME = System.currentTimeMillis();

    @Value("${INSTANCE_NAME:BLUE}")
    private String instanceName;

    @GetMapping("/api/uptime")
    public Map<String, Object> uptime() {
        Map<String, Object> response = new HashMap<>();
        response.put("instance", instanceName);
        response.put("uptime_seconds", (System.currentTimeMillis() - START_TIME) / 1000);
        return response;
    }
}

@RestController
class CalcController {

    private final Calculator calculator = new Calculator();

    @GetMapping("/api/calc/add")
    public Map<String, Object> add(@RequestParam(defaultValue = "0") int a, @RequestParam(defaultValue = "0") int b) {
        Map<String, Object> response = new HashMap<>();
        response.put("operation", "add");
        response.put("a", a);
        response.put("b", b);
        response.put("result", calculator.add(a, b));
        return response;
    }

    @GetMapping("/api/calc/multiply")
    public Map<String, Object> multiply(@RequestParam(defaultValue = "0") int a, @RequestParam(defaultValue = "0") int b) {
        Map<String, Object> response = new HashMap<>();
        response.put("operation", "multiply");
        response.put("a", a);
        response.put("b", b);
        response.put("result", calculator.multiply(a, b));
        return response;
    }
}