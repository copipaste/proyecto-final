package com.cicd.webapi;

import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.mockStatic;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class WebapiApplicationTests {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void contextLoads() {
	}

	@Test
	void main_shouldStartSpringApplication() {
		String[] args = {};

		try (MockedStatic<SpringApplication> mocked = mockStatic(SpringApplication.class)) {
			WebapiApplication.main(args);
			mocked.verify(() -> SpringApplication.run(WebapiApplication.class, args));
		}
	}

	@Test
	void checkRootResponse() throws Exception {
		mockMvc.perform(get("/")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.message").value("Hello CI/CD World!"))
			.andExpect(jsonPath("$.status").value("running"));
	}

	@Test
	void checkHealthyResponse() throws Exception {
		mockMvc.perform(get("/health")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("UP"))
			.andExpect(jsonPath("$.message").value("Server Healthy!"));
	}

	@Test
	void checkDateResponse() throws Exception {
		mockMvc.perform(get("/date")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.date").exists());
	}

	@Test
	void checkInstanceResponse() throws Exception {
		mockMvc.perform(get("/api/instance")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.instance").exists())
			.andExpect(jsonPath("$.port").exists())
			.andExpect(jsonPath("$.status").value("ACTIVE"));
	}

	@Test
	void checkInfoResponse() throws Exception {
		mockMvc.perform(get("/api/info")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.application").value("Diplomado CI/CD WebAPI"));
	}

	@Test
	void checkCalcAddResponse() throws Exception {
		mockMvc.perform(get("/api/calc/add?a=10&b=20")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.result").value(30));
	}

	@Test
	void checkCalcMultiplyResponse() throws Exception {
		mockMvc.perform(get("/api/calc/multiply?a=5&b=6")
				.accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.result").value(30));
	}
}
