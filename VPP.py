import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
import random
import matplotlib.pyplot as plt


class VirtualPowerPlant:
    def __init__(self, max_wind, max_solar, max_demand, min_soc, max_soc, max_charge, max_discharge):
        self.max_wind = max_wind
        self.max_solar = max_solar
        self.max_demand = max_demand
        self.min_soc = min_soc
        self.max_soc = max_soc
        self.max_charge = max_charge
        self.max_discharge = max_discharge
        self.soc = (min_soc + max_soc) / 2  # 초기 SOC는 중간 값으로 설정

    def reset(self):
        self.soc = (self.min_soc + self.max_soc) / 2
        return self._get_state()

    def step(self, action):
        wind_power = np.random.uniform(0, self.max_wind)
        solar_power = np.random.uniform(0, self.max_solar)
        demand = np.random.uniform(0, self.max_demand)
        price = np.random.uniform(0, 1)  # 단순화를 위해 가격을 [0, 1] 사이의 값으로 설정

        if action == 0:  # 최대 충전
            charge = self.max_charge
        elif action == 1:  # 절반 충전
            charge = self.max_charge / 2
        elif action == 2:  # 충전 및 방전 없음
            charge = 0
        elif action == 3:  # 절반 방전
            charge = -self.max_discharge / 2
        elif action == 4:  # 최대 방전
            charge = -self.max_discharge

        new_soc = self.soc + charge
        if new_soc > self.max_soc:
            charge = self.max_soc - self.soc
            new_soc = self.max_soc
        elif new_soc < self.min_soc:
            charge = self.min_soc - self.soc
            new_soc = self.min_soc

        self.soc = new_soc
        reward = price * (wind_power + solar_power - demand + charge)
        state = self._get_state()
        return state, reward

    def _get_state(self):
        return np.array([self.soc])


class DQNAgent:
    def __init__(self, state_size, action_size):
        self.state_size = state_size
        self.action_size = action_size
        self.memory = []
        self.gamma = 0.95
        self.epsilon = 1.0
        self.epsilon_min = 0.01
        self.epsilon_decay = 0.995
        self.learning_rate = 0.001
        self.model = self._build_model()

    def _build_model(self):
        model = Sequential()
        model.add(Dense(24, input_dim=self.state_size, activation='relu'))
        model.add(Dense(24, activation='relu'))
        model.add(Dense(self.action_size, activation='linear'))
        model.compile(loss='mse', optimizer=Adam(lr=self.learning_rate))
        return model

    def remember(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))

    def act(self, state):
        if np.random.rand() <= self.epsilon:
            return random.randrange(self.action_size)
        act_values = self.model.predict(state)
        return np.argmax(act_values[0])

    def replay(self, batch_size):
        minibatch = random.sample(self.memory, batch_size)
        for state, action, reward, next_state, done in minibatch:
            target = reward
            if not done:
                target = (reward + self.gamma *
                          np.amax(self.model.predict(next_state)[0]))
            target_f = self.model.predict(state)
            target_f[0][action] = target
            self.model.fit(state, target_f, epochs=1, verbose=0)
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def load(self, name):
        self.model.load_weights(name)

    def save(self, name):
        self.model.save_weights(name)


if __name__ == "__main__":
    env = VirtualPowerPlant(max_wind=1.5, max_solar=1.0, max_demand=0.5, min_soc=0.1, max_soc=1.0, max_charge=0.6,
                            max_discharge=0.6)
    state_size = env._get_state().shape[0]
    action_size = 5
    agent = DQNAgent(state_size, action_size)
    done = False
    batch_size = 32
    episodes = 1000
    total_rewards = []

    for e in range(episodes):
        state = env.reset()
        state = np.reshape(state, [1, state_size])
        total_reward = 0
        for time in range(200):
            action = agent.act(state)
            next_state, reward = env.step(action)
            total_reward += reward
            next_state = np.reshape(next_state, [1, state_size])
            agent.remember(state, action, reward, next_state, done)
            state = next_state
            if len(agent.memory) > batch_size:
                agent.replay(batch_size)

            # 결과 출력 부분
            print(
                f"Episode: {e + 1}, Time: {time + 1}, Action: {action}, Reward: {reward:.2f}, Total Reward: {total_reward:.2f}, SOC: {state[0][0]:.2f}, Epsilon: {agent.epsilon:.2f}")

        total_rewards.append(total_reward)
        print(f"Episode {e + 1} finished with Total Reward: {total_reward:.2f}")

    # 총 보상을 시각화
    plt.plot(range(1, episodes + 1), total_rewards)
    plt.xlabel('Episode')
    plt.ylabel('Total Reward')
    plt.title('Total Reward per Episode')
    plt.show()

    agent.save("dqn_vpp.h5")
