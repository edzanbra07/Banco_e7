package app.dto;

import java.time.Instant;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ApiResponse<T> {

	private final boolean success;
	private final String message;
	private final T data;
	private final Instant timestamp;
	private final String path;

	public static <T> ApiResponse<T> success(String message, T data, String path) {
		return ApiResponse.<T>builder()
			.success(true)
			.message(message)
			.data(data)
			.timestamp(Instant.now())
			.path(path)
			.build();
	}

	public static <T> ApiResponse<T> error(String message, String path) {
		return ApiResponse.<T>builder()
			.success(false)
			.message(message)
			.data(null)
			.timestamp(Instant.now())
			.path(path)
			.build();
	}
}